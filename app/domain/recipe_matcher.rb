
# Here we apply product logic: it encapsulates how we score a recipe match
class RecipeMatcher
  attr_reader :user_ingredient_ids

  def initialize(user_ingredient_ids)
    @user_ingredient_ids = Array(user_ingredient_ids).presence || []
  end

  def score_for(total_ings:, matched_ings:)
    return 0.0 if total_ings.to_i <= 0

    ratio   = matched_ings.to_f / total_ings.to_f
    missing = total_ings - matched_ings

    ratio - 0.05 * missing
  end
end