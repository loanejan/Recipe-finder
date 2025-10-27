require "test_helper"

class Api::RecipesControllerTest < ActionDispatch::IntegrationTest
  # On empêche toute requête ActiveRecord dans ce test en stubbant RecipeSearch et RecipeDetail,
  # qui sont les SEULES choses appelées par le contrôleur.

  test "GET /api/recipes returns search results as JSON" do
    fake_result = {
      "recipes" => [
        {
          "id" => 123,
          "title" => "Pasta Carbonara",
          "image" => "https://example.com/carbo.jpg",
          "total_time" => 20,
          "yields" => "2 servings",
          "total_ings" => 5,
          "matched_ings" => 3
        }
      ],
      "pagination" => {
        "page" => 1,
        "per_page" => 20,
        "total_count" => 1,
        "has_next_page" => false
      }
    }

    # Ici on stub RecipeSearch.call entièrement.
    # Peu importe la DB, on renvoie ce qu'on veut.
    RecipeSearch.stub :call, fake_result do
      get "/api/recipes", params: {
        ing: "tomate basilic",
        page: "2",
        per_page: "10"
      }

      assert_response :success

      body = JSON.parse(response.body)
      assert_equal fake_result, body
    end
  end

  test "GET /api/recipes/:id returns the recipe details as JSON" do
    fake_recipe = {
      "id" => 42,
      "title" => "Shakshuka",
      "total_time" => 25,
      "yields" => "2 servings",
      "image" => "https://example.com/shak.jpg",
      "ingredients" => [
        { "id" => 1, "name" => "egg", "raw" => "2 eggs" },
        { "id" => 2, "name" => "tomato", "raw" => "1 can crushed tomatoes" }
      ]
    }

    RecipeDetail.stub :call, fake_recipe do
      get "/api/recipes/42"

      assert_response :success

      body = JSON.parse(response.body)
      assert_equal fake_recipe, body
    end
  end

  test "GET /api/recipes/:id returns 404 if recipe not found" do
    # ici pareil : pas de DB.
    # On simule le service qui lève l'erreur.
    RecipeDetail.stub(:call, ->(id:) { raise ActiveRecord::RecordNotFound }) do
      get "/api/recipes/999999"
      assert_response :not_found
    end
  end
end
