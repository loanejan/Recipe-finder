import { useState, KeyboardEvent } from "react";

type IngredientChipsInputProps = {
  ingredients: string[];
  onChange: (next: string[]) => void;
  placeholder?: string;
  label?: string;
};

export default function IngredientChipsInput({
  ingredients,
  onChange,
  placeholder = "e.g. egg, tomato, garlic",
  label = "Extra ingredients"
}: IngredientChipsInputProps) {
  const [draft, setDraft] = useState("");

  function addChipFromDraft() {
    const cleaned = draft.trim().toLowerCase();
    if (cleaned !== "" && !ingredients.includes(cleaned)) {
      onChange([...ingredients, cleaned]);
    }
    setDraft("");
  }

  function handleKeyDown(e: KeyboardEvent<HTMLInputElement>) {
    if (e.key === "Enter" || e.key === "," ) {
      e.preventDefault();
      addChipFromDraft();
    }
  }

  function removeChip(name: string) {
    onChange(ingredients.filter((ing) => ing !== name));
  }

  return (
    <div className="space-y-2">
      <div className="text-sm font-medium text-brand-text">{label}</div>

      <div className="rounded-xl2 bg-brand-card border border-white/10 px-3 py-2 shadow-soft">
        {/* chips row */}
        <div className="flex flex-wrap gap-2 mb-2">
          {ingredients.map((ing) => (
            <span
              key={ing}
              className="inline-flex items-center gap-2 rounded-full bg-brand-primary/15 text-brand-primary text-xs font-medium px-3 py-1 border border-brand-primary/30"
            >
              <span>{ing}</span>
              <button
                type="button"
                onClick={() => removeChip(ing)}
                className="text-brand-primary/70 hover:text-brand-primary/100 text-[10px] leading-none"
                aria-label={`Remove ${ing}`}
              >
                ✕
              </button>
            </span>
          ))}
        </div>

        {/* input row */}
        <input
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          onKeyDown={handleKeyDown}
          onBlur={addChipFromDraft} // user clicks away -> commit current draft
          placeholder={placeholder}
          className="w-full bg-transparent text-sm text-brand-text placeholder-brand-muted focus:outline-none"
        />
      </div>

      <p className="text-[11px] text-brand-muted leading-snug">
        Press Enter or comma to add each ingredient.
      </p>
    </div>
  );
}
