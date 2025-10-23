import { useQuery } from "@tanstack/react-query";
import { api } from "@/api";
import type { RecipeDetail, RecipeListItem } from "@/types";
import { keys } from "./keys";

export function useRecipes(q: string) {
  return useQuery({
    queryKey: keys.recipes(q),
    queryFn: async (): Promise<RecipeListItem[]> =>
      (await api.get("/recipes", { params: { q } })).data,
  });
}

export function useRecipe(id: number) {
  return useQuery({
    queryKey: keys.recipe(id),
    queryFn: async (): Promise<RecipeDetail> => (await api.get(`/recipes/${id}`)).data,
    enabled: !!id,
  });
}
