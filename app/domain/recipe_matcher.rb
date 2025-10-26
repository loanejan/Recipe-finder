# app/domain/recipe_matcher.rb
#
# RecipeMatcher encapsulates how we score a recipe match.
# We don't touch ActiveRecord here; we just apply product logic.
#
class RecipeMatcher
  attr_reader :user_ingredient_ids

  def initialize(user_ingredient_ids)
    # user_ingredient_ids = array of ingredient IDs considered "available"
    @user_ingredient_ids = Array(user_ingredient_ids).presence || []
  end

  # Returns a numeric score. Higher = more relevant.
  #
  # We expect:
  #   total_ings   : number of DISTINCT ingredients in the recipe
  #   matched_ings : number of DISTINCT ingredients the user already has
  #
  # score formula:
  #   ratio = matched_ings / total_ings
  #   missing = total_ings - matched_ings
  #   score = ratio - 0.05 * missing
  #
  def score_for(total_ings:, matched_ings:)
    return 0.0 if total_ings.to_i <= 0

    ratio   = matched_ings.to_f / total_ings.to_f
    missing = total_ings - matched_ings

    ratio - 0.05 * missing
  end
end
