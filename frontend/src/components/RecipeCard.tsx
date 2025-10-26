import { Link } from "react-router-dom";
import React from "react";
import type { RecipeListItem } from "@/hooks/useRecipesPaginated";

interface RecipeCardProps {
  r: RecipeListItem;
}

export default function RecipeCard({ r }: RecipeCardProps) {
  return (
    <Link
      to={`/recipes/${r.id}`}
      className="block rounded-xl2 overflow-hidden bg-brand-card border border-white/5 shadow-soft hover:shadow-md hover:border-brand-primary/40 transition-shadow transition-colors"
    >
      {/* Image si dispo */}
      {r.image && (
        <img
          src={r.image}
          alt={r.title}
          onError={(e) => {
            (e.currentTarget as HTMLImageElement).src =
              "/placeholder-recipe.jpg";
          }}
          className="w-full max-h-[300px] object-cover"
        />
      )}

      <div className="p-4 space-y-2">
        {/* Titre */}
        <h2 className="text-base font-semibold text-brand-text leading-snug line-clamp-2 group-hover:text-brand-text/90">
          {r.title}
        </h2>

        {/* Meta row conditionnelle */}
        <div className="text-sm text-brand-muted flex flex-wrap gap-2">
          {r.total_time && (
            <span className="flex items-center gap-1">
              <span role="img" aria-label="time">
                ⏱
              </span>
              <span>{r.total_time} min</span>
            </span>
          )}

          {r.yields && (
            <span className="flex items-center gap-1">
              <span role="img" aria-label="servings">
                🍽
              </span>
              <span>{r.yields}</span>
            </span>
          )}

          {r.total_ings != null &&
            r.matched_ings != null && (
              <span className="flex items-center gap-1">
                <span role="img" aria-label="match">
                  ✅
                </span>
                <span>
                  {r.matched_ings}/{r.total_ings} ingrédients
                </span>
              </span>
            )}
        </div>
      </div>
    </Link>
  );
}
