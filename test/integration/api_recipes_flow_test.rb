require "test_helper"

class Api::RecipesErrorFlowTest < ActionDispatch::IntegrationTest

  test "#show respond 200 if the recipe exists" do
    recipe = Recipe.create!(title: "Pâtes aux champignons")

    get "/api/recipes/#{recipe.id}"

    assert_response :success
  end

  test "#show respond 404 if the recipe doesnt exist" do
    get "/api/recipes/999999"

    assert_response :not_found

    body = JSON.parse(@response.body)
    assert_equal "Recipe not found", body["error"]
  end

  test "#index respond 200 if search is a success" do
    Recipe.create!(title: "Ratatouille")

    get "/api/recipes"

    assert_response :success
  end

  test "#index respond 422 if the search fails" do
    get "/api/recipes", params: { ing: "tomato", per_page: { nope: "bad" } }

    assert_response :unprocessable_entity

    body = JSON.parse(@response.body)
    assert_equal "Search failed", body["error"]
    assert body["details"].present?
  end
end
