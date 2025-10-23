import { useState } from "react";
import { useAddPantryItem, useDeletePantryItem, usePantry } from "@/queries/pantry";

export default function PantryPage() {
  const { data: items, isLoading } = usePantry();
  const add = useAddPantryItem();
  const del = useDeletePantryItem();
  const [name, setName] = useState("");

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;
    await add.mutateAsync(name.trim());
    setName("");
  };

  return (
    <section>
      <h2 className="text-2xl font-semibold mb-3">My pantry</h2>
      <form onSubmit={onSubmit} className="flex gap-2 mb-4">
        <input
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="Add ingredient (tomato)"
          className="flex-1 bg-brand-card border border-white/5 rounded-xl2 px-3 py-2"
        />
        <button className="px-3 py-2 rounded-xl2 bg-brand-primary/90 hover:bg-brand-primary">
          Add
        </button>
      </form>
      {isLoading ? (
        <p className="text-brand-muted">Loading…</p>
      ) : (
        <ul className="space-y-1">
          {(items ?? []).map((it) => (
            <li key={it.id} className="flex items-center gap-2">
              <span className="flex-1">{it.name}</span>
              <button
                onClick={() => del.mutate(it.id)}
                className="text-sm text-brand-muted hover:text-brand-text"
              >
                ✕
              </button>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
