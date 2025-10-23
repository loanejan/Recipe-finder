import { Link } from "react-router-dom";
import type { RecipeListItem } from "@/types";
export default function RecipeCard({ r }: { r: RecipeListItem }) {
  return (
    <Link to={`/recipes/${r.id}`} className="group">
      <article className="overflow-hidden rounded-xl2 bg-brand-card border border-white/5 shadow-soft hover:border-brand-primary/40 transition">
        {r.image && (
          <img
            src={r.image}
            alt={r.title}
            className="aspect-video w-full object-cover opacity-95 group-hover:opacity-100"
          />
        )}
        <div className="p-4">
          <h3 className="font-medium leading-snug group-hover:text-brand-text">{r.title}</h3>
          <p className="mt-1 text-xs text-brand-muted">
            {r.matched_ings != null && r.total_ings != null ? (
              <span>
                {r.matched_ings}/{r.total_ings} matched
              </span>
            ) : (
              <span>
                {r.total_time ? `${r.total_time} min` : "Time n/a"} · {r.yields ?? "Servings n/a"}
              </span>
            )}
          </p>
        </div>
      </article>
    </Link>
  );
}
