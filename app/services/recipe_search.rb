# app/services/recipe_search.rb
#
# Use case:
#   Given query terms, return a (paginated) list of recipes
#   ranked by how well they match the user's available ingredients.
#
# This version:
# - counts DISTINCT ingredients per recipe
# - counts DISTINCT matched ingredients
# - returns total_ings and matched_ings consistent with what the UI displays
#
class RecipeSearch
    def self.call(query:, page:, per_page:)
      new(
        query:        query,
        page:         page,
        per_page:     per_page
      ).call
    end
  
    def initialize(query:, page:, per_page:)
      @query        = query
      @page         = (page.presence || 1).to_i
      @per_page     = (per_page.presence || 20).to_i
    end
  
    def call
      terms = build_terms
  
      if terms.empty?
        return paginated_result_from_array(fallback_recipes)
      end
  
      all_ids, id_to_term = match_ingredients_by_term(terms)
      return paginated_result_from_array([]) if all_ids.empty?
  
      scored = score_candidates_in_ruby(all_ids, id_to_term)
      paginated_result_from_array(scored)
    end
  
    private
  
    def build_terms
      quick_terms = @query
        .to_s
        .downcase
        .split(/[,\s]+/)
        .reject(&:blank?)
  
      (quick_terms).uniq
    end
  
    # Retourne deux choses :
    # - all_ids: tous les ingredient_ids qui matchent un des termes
    # - id_to_term: un hash { ingredient_id => terme_utilisateur }
    def match_ingredients_by_term(terms)
      id_to_term = {}
    
      terms.each do |term|
        matches = Ingredient
          .where("lower(name) LIKE ?", "%#{term.downcase}%")
          .pluck(:id)
      
        matches.each do |ing_id|
          id_to_term[ing_id] = term
        end
      end
    
      all_ids = id_to_term.keys
      [all_ids, id_to_term]
    end
    
      
    def score_candidates_in_ruby(user_ing_ids, id_to_term)
      return [] if user_ing_ids.blank?
    
      matcher = RecipeMatcher.new(user_ing_ids)
    
      # 1. recettes candidates = celles qui utilisent AU MOINS un ingredient_id mentionné
      candidates = Recipe
        .joins(:recipe_ingredients)
        .where(recipe_ingredients: { ingredient_id: user_ing_ids })
        .distinct
    
      return [] if candidates.empty?
    
      recipe_ids = candidates.pluck(:id)
    
      # 2. on récupère tous les ingrédients (ids) pour ces recettes en une seule fois
      rows = RecipeIngredient
        .where(recipe_id: recipe_ids)
        .pluck(:recipe_id, :ingredient_id)
    
      # 3. on construit, en mémoire:
      #    ingredients_by_recipe[recipe_id] = [ingredient_id1, ingredient_id2, ...]
      ingredients_by_recipe = {}
      rows.each do |recipe_id, ingredient_id|
        (ingredients_by_recipe[recipe_id] ||= []) << ingredient_id
      end
    
      ingredients_by_recipe.each do |rid, ing_list|
        ingredients_by_recipe[rid] = ing_list.uniq
      end
    
      # 4. on construit la réponse finale pour chaque recette
      scored = candidates.map do |recipe|
        recipe_ing_ids = ingredients_by_recipe[recipe.id] || []
      
        total_ings = recipe_ing_ids.size
      
        # ---- NOUVEAU CALCUL matched_ings ----
        #
        # On veut compter combien de "termes utilisateur" couvrent les ingrédients de la recette,
        # sans jamais compter deux fois le même terme.
        #
        # Exemple :
        #   recette a [12, 57] (sel fin, sel gros)
        #   id_to_term[12] = "sel"
        #   id_to_term[57] = "sel"
        #   => matched_terms = ["sel"] => size = 1
        #
        matched_terms = recipe_ing_ids.map { |iid| id_to_term[iid] }.compact.uniq
        matched_ings  = matched_terms.size
      
        # score métier basé sur matched_ings/total_ings
        score = matcher.score_for(
          total_ings:   total_ings,
          matched_ings: matched_ings
        )
      
        {
          id:           recipe.id,
          title:        recipe.title,
          image:        recipe.image,
          total_time:   recipe.total_time,
          yields:       recipe.yields || nil,
          total_ings:   total_ings,
          matched_ings: matched_ings,
          _score:       score
        }
      end
    
      scored.sort_by { |h| -h[:_score] }
    end



    # 4. Fallback si pas de termes : top recettes sans scoring
    #    (par exemple les 50 premières juste pour ne pas renvoyer vide)
    def fallback_recipes
      Recipe
        .includes(:recipe_ingredients)
        .limit(100) # assez grand pour pagination
        .map do |r|
          # même logique DISTINCT pour rester cohérent
          recipe_ing_ids = r.recipe_ingredients.map(&:ingredient_id).uniq
  
          {
            id:           r.id,
            title:        r.title,
            image:        r.image,
            total_time:   r.total_time,
            yields:     r.yields || nil,
            total_ings:   recipe_ing_ids.size,
            matched_ings: nil,   # pas de notion de match sans termes
            _score:       0.0
          }
        end
    end
  
    # 5. Paginate the full array of recipe hashes (already scored/sorted)
    def paginated_result_from_array(full_array)
      total_count = full_array.size
      offset      = (@page - 1) * @per_page
      slice       = full_array.slice(offset, @per_page) || []
  
      {
        recipes: slice.map { |h| h.except(:_score) },
        pagination: {
          page:          @page,
          per_page:      @per_page,
          total_count:   total_count,
          has_next_page: (offset + @per_page) < total_count
        }
      }
    end
end  