import { useInfiniteQuery } from "@tanstack/react-query";

export type RecipeListItem = {
  id: number;
  title: string;
  image: string | null;
  total_time: number | null;
  servings: string | null;
  total_ings: number | null;
  matched_ings: number | null;
};

export type RecipePageResponse = {
  recipes: RecipeListItem[];
  pagination: {
    page: number;
    per_page: number;
    total_count: number;
    has_next_page: boolean;
  };
};

// turn ["egg","tomato"] -> "egg,tomato"
function buildQueryParamFromIngredients(extraIngredients: string[]) {
  return extraIngredients.join(",");
}

// Fetch a single page from backend with pantry + extras
async function fetchRecipesPage(pageParam: number, extraIngredients: string[]) {
  const params = new URLSearchParams({
    page: String(pageParam),
    per_page: "20",
  });

  const q = buildQueryParamFromIngredients(extraIngredients);
  if (q.trim() !== "") {
    params.set("q", q);
  }

  const res = await fetch(`/api/recipes?${params.toString()}`);
  if (!res.ok) {
    throw new Error(`Failed to fetch recipes page ${pageParam}`);
  }
  const data: RecipePageResponse = await res.json();
  return data;
}

// Hook with infinite pagination + "chips" as input
export function usePaginatedRecipesQuery(extraIngredients: string[]) {
  return useInfiniteQuery({
    queryKey: ["recipes", extraIngredients],
    queryFn: ({ pageParam = 1 }) =>
      fetchRecipesPage(pageParam, extraIngredients),
    getNextPageParam: (lastPage) => {
      if (lastPage.pagination.has_next_page) {
        return lastPage.pagination.page + 1;
      }
      return undefined;
    },
  });
}
