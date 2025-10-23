import { useParams, Link } from "react-router-dom";
import Loader from "@/components/Loader";
import { useRecipe } from "@/queries/recipes";

export default function RecipePage() {
  const { id } = useParams();
  const rid = Number(id);
  const { data: recipe, isLoading } = useRecipe(rid);
  if (isLoading || !recipe) return <Loader />;
  return (
    <section className="space-y-4">
      <Link to="/" className="text-sm text-brand-muted hover:text-brand-text">
        ← Back to list
      </Link>
      <div className="rounded-xl2 overflow-hidden bg-brand-card border border-white/5 shadow-soft">
        {recipe.image && (
          <img
            src={recipe.image}
            alt={recipe.title}
            className="w-full max-h-[420px] object-cover"
          />
        )}
        <div className="p-5">
          <h1 className="text-2xl font-semibold">{recipe.title}</h1>
          <p className="text-sm text-brand-muted mt-1">
            {recipe.total_time ? `${recipe.total_time} min` : "Time n/a"} ·{" "}
            {recipe.yields ?? "Servings n/a"}
          </p>
          <h3 className="mt-5 font-medium">Ingredients</h3>
          <ul className="mt-2 grid gap-2 sm:grid-cols-2">
            {recipe.ingredients.map((i) => (
              <li key={i.id} className="text-sm text-brand-text/90">
                {i.raw || i.name}
              </li>
            ))}
          </ul>
          {recipe.url && (
            <a
              href={recipe.url}
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-2 mt-5 text-sm text-brand-primary hover:underline"
            >
              View source ↗
            </a>
          )}
        </div>
      </div>
    </section>
  );
}
