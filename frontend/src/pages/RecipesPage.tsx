import { useEffect, useMemo, useState } from "react";
import { useSearchParams } from "react-router-dom";
import TagInput from "@/components/TagInput";
import RecipeCard from "@/components/RecipeCard";
import Loader from "@/components/Loader";
import EmptyState from "@/components/EmptyState";
import { useRecipes } from "@/queries/recipes";

export default function RecipesPage() {
  const [params, setParams] = useSearchParams();
  const [tags, setTags] = useState<string[]>(
    () =>
      params
        .get("q")
        ?.split(/[\s,]+/)
        .filter(Boolean) ?? [],
  );
  const query = useMemo(() => tags.join(","), [tags]);
  const { data, isLoading } = useRecipes(query);

  useEffect(() => {
    setParams(query ? { q: query } : {});
  }, [query, setParams]);

  return (
    <section className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">Find recipes</h1>
        <p className="text-sm text-brand-muted">
          Type ingredients and press Enter to add them as tags.
        </p>
        <div className="mt-3">
          <TagInput value={tags} onChange={setTags} placeholder="egg, milk, tomato" />
        </div>
      </div>
      {isLoading ? (
        <Loader />
      ) : !data || data.length === 0 ? (
        <EmptyState
          title="No recipes found"
          hint="Try removing some tags or adding more common ingredients."
        />
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {data.map((r) => (
            <RecipeCard key={r.id} r={r} />
          ))}
        </div>
      )}
    </section>
  );
}
