import { useCallback, useMemo } from "react";
import { useSearchParams } from "react-router-dom";
import IngredientChipsInput from "@/components/IngredientChipsInput";
import RecipeCard from "@/components/RecipeCard";
import { RecipeListItem, useRecipesPaginated } from "@/hooks/useRecipesPaginated";

function parseIngsParam(sp: URLSearchParams): string[] {
  const raw = sp.get("q");
  if (!raw) return [];
  return raw
    .split(",")
    .map((s) => s.trim().toLowerCase())
    .filter((s) => s.length > 0);
}

function serializeIngsParam(q: string[]): string {
  return q.join(",");
}

export default function RecipesPage() {
  const [searchParams, setSearchParams] = useSearchParams();

  // chips -> dérivées de l'URL (?a=egg,tomato)
  const extraIngredients = useMemo(() => parseIngsParam(searchParams), [searchParams]);

  // quand on modifie les chips, on met à jour l'URL
  // (ça re-triggera le hook useRecipesPaginated car extraIngredients change)
  const handleChangeIngredients = useCallback(
    (nextIngredients: string[]) => {
      const next = new URLSearchParams(searchParams);
      if (nextIngredients.length === 0) {
        next.delete("q");
      } else {
        next.set("q", serializeIngsParam(nextIngredients));
      }
      setSearchParams(next, { replace: true });
    },
    [searchParams, setSearchParams],
  );

  const { recipes, initialLoading, loadingMore, hasNextPage, loadMore, error } =
    useRecipesPaginated(extraIngredients);

  return (
    <main className="p-6 space-y-8 max-w-6xl mx-auto">
      <section className="space-y-4">
        <div>
          <h1 className="text-xl font-semibold text-brand-text">Recipes for you</h1>
          <p className="text-sm text-brand-muted">
            Based on your pantry and the ingredients you want to use.
          </p>
        </div>

        <IngredientChipsInput
          ingredients={extraIngredients}
          onChange={handleChangeIngredients}
          label="Add ingredients you want to use"
          placeholder="e.g. egg, tomato, garlic"
        />

        {initialLoading && <p className="text-[11px] text-brand-muted">Loading recipes…</p>}
      </section>

      {error ? (
        <div className="text-red-400 text-sm">Couldn't load recipes. Please try again.</div>
      ) : !initialLoading && recipes.length === 0 ? (
        <div className="text-brand-muted text-sm">No recipes found for those ingredients.</div>
      ) : (
        <>
          <section className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {recipes.map((r: RecipeListItem) => (
              <RecipeCard key={r.id} r={r} />
            ))}
          </section>

          <section className="flex justify-center pb-12">
            {hasNextPage ? (
              <button
                onClick={loadMore}
                disabled={loadingMore}
                className="rounded-xl2 bg-brand-primary text-white px-4 py-2 text-sm font-medium shadow-soft hover:bg-brand-primary/90 disabled:opacity-50"
              >
                {loadingMore ? "Loading…" : "Load more"}
              </button>
            ) : (
              <p className="text-xs text-brand-muted">You’ve reached the end.</p>
            )}
          </section>
        </>
      )}
    </main>
  );
}
