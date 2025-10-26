import { useEffect, useState } from "react";

export type RecipeIngredientDetail = {
  id: number;
  name: string;
  raw: string;
};

export type RecipeDetail = {
  id: number;
  title: string;
  total_time: number | null;
  yields?: string | null; // si tu renvoies encore `yields`, remplace par `yields?: string | null`
  image: string | null;
  url: string | null;
  ingredients: RecipeIngredientDetail[];
};

export function useRecipeDetail(id: string | number | undefined) {
  const [data, setData] = useState<RecipeDetail | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!id) return;

    let cancelled = false;

    async function load() {
      setLoading(true);
      setError(null);

      try {
        const res = await fetch(`/api/recipes/${id}`);
        if (!res.ok) {
          throw new Error("Failed to fetch recipe");
        }
        const json: RecipeDetail = await res.json();
        if (cancelled) return;

        setData(json);
      } catch (err: any) {
        if (!cancelled) {
          setError(err.message ?? "Error");
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    load();

    return () => {
        cancelled = true;
    };
  }, [id]);

  return { data, loading, error };
}
