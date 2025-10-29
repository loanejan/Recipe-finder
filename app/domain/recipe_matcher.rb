# Here we apply product logic: it encapsulates how we score a recipe match
class RecipeMatcher
  def score_for(total_ings:, matched_ings:)
    return 0.0 if total_ings.to_i <= 0

    ratio   = matched_ings.to_f / total_ings.to_f
    missing = total_ings - matched_ings

    ratio - 0.05 * missing
  end
end