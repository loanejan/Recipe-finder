export type PantryItem = { id: number; name: string };
export type RecipeListItem = {
  id: number;
  title: string;
  image?: string | null;
  total_time?: number | null;
  yields?: string | null;
  total_ings?: number;
  matched_ings?: number;
};
export type RecipeDetail = {
  id: number;
  title: string;
  total_time?: number | null;
  yields?: string | null;
  image?: string | null;
  url?: string | null;
  ingredients: { id: number; name: string; raw?: string | null }[];
};
