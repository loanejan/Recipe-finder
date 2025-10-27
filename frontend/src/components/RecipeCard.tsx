import { Link } from "react-router-dom";
import type { RecipeListItem } from "@/hooks/useRecipesPaginated";

interface RecipeCardProps {
  recipe: RecipeListItem;
}

export default function RecipeCard({ recipe }: RecipeCardProps) {
  return (
    <Link
      to={`/recipes/${recipe.id}`}
      className="block rounded-xl2 overflow-hidden bg-brand-card border border-white/5 shadow-soft hover:shadow-md hover:border-brand-primary/40 transition-shadow transition-colors"
    >
      {recipe.image && (
        <img
          src={recipe.image}
          alt={recipe.title}
          onError={(e) => {
            (e.currentTarget as HTMLImageElement).src = "/placeholder-recipe.jpg";
          }}
          className="w-full max-h-[300px] object-cover"
        />
      )}

      <div className="p-4 space-y-2">
        <h2 className="text-base font-semibold text-brand-text leading-snug line-clamp-2 group-hover:text-brand-text/90">
          {recipe.title}
        </h2>

        <div className="text-sm text-brand-muted flex flex-wrap gap-2">
          {recipe.total_time != null && recipe.total_time > 0 && (
            <span className="flex items-center gap-1">
              <span role="img" aria-label="time">
                ⏱
              </span>
              <span>{recipe.total_time} min</span>
            </span>
          )}

          {recipe.total_ings != null && recipe.matched_ings != null && (
            <span className="flex items-center gap-1">
              <span role="img" aria-label="match">
                ✅
              </span>
              <span>
                {recipe.matched_ings}/{recipe.total_ings} ingrédients
              </span>
            </span>
          )}
        </div>
      </div>
    </Link>
  );
}
