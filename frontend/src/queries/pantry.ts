import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { api } from "@/api";
import type { PantryItem } from "@/types";
import { keys } from "./keys";

export function usePantry() {
  return useQuery({
    queryKey: keys.pantry,
    queryFn: async (): Promise<PantryItem[]> => (await api.get("/pantry_items")).data,
  });
}

export function useAddPantryItem() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (name: string) =>
      (await api.post("/pantry_items", { name })).data as PantryItem,
    onMutate: async (name) => {
      await qc.cancelQueries({ queryKey: keys.pantry });
      const prev = qc.getQueryData<PantryItem[]>(keys.pantry);
      if (prev) qc.setQueryData<PantryItem[]>(keys.pantry, [...prev, { id: Date.now(), name }]);
      return { prev };
    },
    onError: (_e, _v, ctx) => {
      if (ctx?.prev) qc.setQueryData(keys.pantry, ctx.prev);
    },
    onSettled: () => qc.invalidateQueries({ queryKey: keys.pantry }),
  });
}

export function useDeletePantryItem() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (id: number) => api.delete(`/pantry_items/${id}`),
    onMutate: async (id) => {
      await qc.cancelQueries({ queryKey: keys.pantry });
      const prev = qc.getQueryData<PantryItem[]>(keys.pantry);
      if (prev)
        qc.setQueryData<PantryItem[]>(
          keys.pantry,
          prev.filter((p) => p.id !== id),
        );
      return { prev };
    },
    onError: (_e, _v, ctx) => {
      if (ctx?.prev) qc.setQueryData(keys.pantry, ctx.prev);
    },
    onSettled: () => qc.invalidateQueries({ queryKey: keys.pantry }),
  });
}
