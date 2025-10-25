import { useCallback, useMemo } from "react";
import { useSearchParams } from "react-router-dom";
import { usePaginatedRecipesQuery } from "@/hooks/usePaginatedRecipesQuery";
import IngredientChipsInput from "@/components/IngredientChipsInput";
import RecipeCard from "@/components/RecipeCard";

function parseIngsParam(sp: URLSearchParams): string[] {
  const raw = sp.get("ings");
  if (!raw) return [];
  return raw
    .split(",")
    .map((s) => s.trim().toLowerCase())
    .filter((s) => s.length > 0);
}

function serializeIngsParam(ings: string[]): string {
  return ings.join(",");
}

export default function RecipesPage() {
  // URL state
  const [searchParams, setSearchParams] = useSearchParams();

  // derive ingredients array from URL
  const extraIngredients = useMemo(() => {
    return parseIngsParam(searchParams);
  }, [searchParams]);

  // when user edits chips, update the URL (which is our single source of truth)
  const handleChangeIngredients = useCallback(
    (nextIngredients: string[]) => {
      const next = new URLSearchParams(searchParams);
      if (nextIngredients.length === 0) {
        next.delete("ings");
      } else {
        next.set("ings", serializeIngsParam(nextIngredients));
      }
      setSearchParams(next, { replace: true });
    },
    [searchParams, setSearchParams]
  );

  // data fetching with React Query
  const {
    data,
    isLoading,
    isError,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isFetching,
  } = usePaginatedRecipesQuery(extraIngredients);

  const allRecipes =
    data?.pages.flatMap((page) => page.recipes) ?? [];

  return (
    <main className="p-6 space-y-8 max-w-6xl mx-auto">
      {/* Header */}
      <section className="space-y-4">
        <div>
          <h1 className="text-xl font-semibold text-brand-text">
            Recipes for you
          </h1>
          <p className="text-sm text-brand-muted">
            Based on your pantry and the ingredients you want to use.
          </p>
        </div>

        {/* Chips input bound to URL */}
        <IngredientChipsInput
          ingredients={extraIngredients}
          onChange={handleChangeIngredients}
          label="Add ingredients you want to use"
          placeholder="e.g. egg, tomato, garlic"
        />

        {isFetching && (
          <p className="text-[11px] text-brand-muted">
            Updating suggestions…
          </p>
        )}
      </section>

      {/* States */}
      {isLoading ? (
        <div className="text-brand-muted text-sm">
          Loading recipes…
        </div>
      ) : isError ? (
        <div className="text-red-400 text-sm">
          Couldn't load recipes. Please try again.
        </div>
      ) : allRecipes.length === 0 ? (
        <div className="text-brand-muted text-sm">
          No recipes found for those ingredients.
        </div>
      ) : (
        <>
          {/* Recipes grid */}
          <section className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {allRecipes.map((r) => (
              <RecipeCard key={r.id} r={r} />
            ))}
          </section>

          {/* Load more / Pagination */}
          <section className="flex justify-center pb-12">
            {hasNextPage ? (
              <button
                onClick={() => fetchNextPage()}
                disabled={isFetchingNextPage}
                className="rounded-xl2 bg-brand-primary text-white px-4 py-2 text-sm font-medium shadow-soft hover:bg-brand-primary/90 disabled:opacity-50"
              >
                {isFetchingNextPage ? "Loading…" : "Load more"}
              </button>
            ) : (
              <p className="text-xs text-brand-muted">
                You’ve reached the end.
              </p>
            )}
          </section>
        </>
      )}
    </main>
  );
}
