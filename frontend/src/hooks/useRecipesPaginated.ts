import { useEffect, useState, useCallback } from "react";

export type RecipeListItem = {
  id: number;
  title: string;
  image: string | null;
  total_time: number | null;
  yields: string | null;
  total_ings: number | null;
  matched_ings: number | null;
};

export type PaginationMeta = {
  page: number;
  per_page: number;
  total_count: number;
  has_next_page: boolean;
};

export type RecipePageResponse = {
  recipes: RecipeListItem[];
  pagination: PaginationMeta;
};

function buildQueryParamFromIngredients(extraIngredients: string[]) {
  return extraIngredients.join(",");
}

export function useRecipesPaginated(extraIngredients: string[]) {
  const [recipes, setRecipes] = useState<RecipeListItem[]>([]);
  const [page, setPage] = useState<number>(1);
  const [hasNextPage, setHasNextPage] = useState<boolean>(true);
  const [initialLoading, setInitialLoading] = useState<boolean>(true);
  const [loadingMore, setLoadingMore] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function loadFirstPage() {
      setInitialLoading(true);
      setError(null);

      try {
        const params = new URLSearchParams({
          page: "1",
          per_page: "20",
        });

        const ing = buildQueryParamFromIngredients(extraIngredients);
        if (ing.trim() !== "") {
          params.set("ing", ing);
        }

        const res = await fetch(`/api/recipes?${params.toString()}`);
        if (!res.ok) {
          throw new Error("Failed to fetch recipes");
        }
        const data: RecipePageResponse = await res.json();
        if (cancelled) return;

        setRecipes(data.recipes);
        setPage(data.pagination.page);
        setHasNextPage(data.pagination.has_next_page);
      } catch (err: any) {
        if (!cancelled) setError(err.message ?? "Error");
      } finally {
        if (!cancelled) setInitialLoading(false);
      }
    }

    loadFirstPage();

    return () => {
      cancelled = true;
    };
  }, [extraIngredients]);

  const loadMore = useCallback(async () => {
    if (!hasNextPage || loadingMore) return;

    setLoadingMore(true);
    setError(null);

    try {
      const nextPage = page + 1;

      const params = new URLSearchParams({
        page: String(nextPage),
        per_page: "20",
      });

      const ing = buildQueryParamFromIngredients(extraIngredients);
      if (ing.trim() !== "") {
        params.set("ing", ing);
      }

      const res = await fetch(`/api/recipes?${params.toString()}`);
      if (!res.ok) {
        throw new Error("Failed to fetch more recipes");
      }
      const data: RecipePageResponse = await res.json();

      setRecipes((prev) => [...prev, ...data.recipes]);
      setPage(data.pagination.page);
      setHasNextPage(data.pagination.has_next_page);
    } catch (err: any) {
      setError(err.message ?? "Error");
    } finally {
      setLoadingMore(false);
    }
  }, [extraIngredients, hasNextPage, loadingMore, page]);

  return {
    recipes,
    initialLoading,
    loadingMore,
    hasNextPage,
    loadMore,
    error,
  };
}
