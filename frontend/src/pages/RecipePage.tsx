import { Link, useParams } from "react-router-dom";
import { useRecipeDetail } from "@/hooks/useRecipeDetail";

export default function RecipePage() {
  // On récupère l'ID de la recette depuis l'URL /recipes/:id
  const { id } = useParams<{ id: string }>();

  const { data: recipe, loading, error } = useRecipeDetail(id);

  if (loading) {
    return (
      <main className="p-6 max-w-3xl mx-auto text-brand-muted text-sm">
        Loading recipe…
      </main>
    );
  }

  if (error || !recipe) {
    return (
      <main className="p-6 max-w-3xl mx-auto text-red-400 text-sm space-y-4">
        <div>Could not load this recipe.</div>
        <Link
          to="/"
          className="inline-block text-brand-primary text-xs hover:underline"
        >
          ← Back to recipes
        </Link>
      </main>
    );
  }

  return (
    <main className="p-6 max-w-3xl mx-auto space-y-8">
      {/* Header nav */}
      <div className="flex items-start justify-between">
        <Link
          to="/"
          className="text-brand-primary text-xs font-medium hover:underline"
        >
          ← Back
        </Link>

        {recipe.url && (
          <a
            href={recipe.url}
            target="_blank"
            rel="noopener noreferrer"
            className="text-xs text-brand-primary hover:underline"
          >
            View original
          </a>
        )}
      </div>

      {/* Card visuelle */}
      <section className="rounded-xl2 overflow-hidden bg-brand-card border border-white/5 shadow-soft">
        {/* Image si dispo */}
        {recipe.image && (
          <img
            src={recipe.image}
            alt={recipe.title}
            onError={(e) => {
              (e.currentTarget as HTMLImageElement).src =
                "/placeholder-recipe.jpg";
            }}
            className="w-full max-h-[420px] object-cover"
          />
        )}

        <div className="p-5 space-y-4">
          {/* Titre */}
          <h1 className="text-xl font-semibold text-brand-text leading-tight">
            {recipe.title}
          </h1>

          {/* Meta résumé */}
          <div className="text-sm text-brand-muted flex flex-wrap gap-x-4 gap-y-2">
            {recipe.total_time && recipe.total_time > 0 && (
              <span className="flex items-center gap-1">
                <span role="img" aria-label="time">
                  ⏱
                </span>
                <span>{recipe.total_time} min</span>
              </span>
            )}

            {recipe.yields && recipe.yields !== "N/A" && (
              <span className="flex items-center gap-1">
                <span role="img" aria-label="yields">
                  🍽
                </span>
                <span>{recipe.yields}</span>
              </span>
            )}
          </div>

          {/* Ingrédients */}
          {recipe.ingredients && recipe.ingredients.length > 0 && (
            <div className="space-y-2">
              <h2 className="text-sm font-medium text-brand-text">
                Ingredients
              </h2>
              <ul className="text-sm text-brand-text/80 space-y-1">
                {recipe.ingredients.map((ing) => (
                  <li
                    key={ing.id}
                    className="flex items-start gap-2 leading-snug"
                  >
                    <span className="text-brand-primary text-xs mt-[3px]">
                      •
                    </span>
                    <span>{ing.raw || ing.name}</span>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      </section>
    </main>
  );
}
