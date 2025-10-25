import { useState } from "react";
import { usePaginatedRecipesQuery } from "@/hooks/usePaginatedRecipesQuery";
import IngredientChipsInput from "@/components/IngredientChipsInput";
import RecipeCard from "@/components/RecipeCard";

export default function RecipesPage() {
  // chips state: ["egg", "tomato", ...]
  const [extraIngredients, setExtraIngredients] = useState<string[]>([]);

  const {
    data,
    isLoading,
    isError,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isFetching, // this is any background refetch
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
            Based on your pantry, plus anything you add below.
          </p>
        </div>

        {/* Chips input */}
        <IngredientChipsInput
          ingredients={extraIngredients}
          onChange={setExtraIngredients}
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

          {/* Load more */}
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
