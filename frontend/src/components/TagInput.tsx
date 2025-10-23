import { useEffect, useRef, useState } from "react";

type Props = { value: string[]; onChange: (tags: string[]) => void; placeholder?: string };
export default function TagInput({ value, onChange, placeholder }: Props) {
  const [input, setInput] = useState("");
  const ref = useRef<HTMLInputElement>(null);
  useEffect(() => {
    ref.current?.focus();
  }, []);
  const commit = () => {
    const parts = input
      .split(/[\s,]+/)
      .map((s) => s.trim())
      .filter(Boolean);
    if (!parts.length) return;
    const next = Array.from(new Set([...value, ...parts]));
    onChange(next);
    setInput("");
  };
  return (
    <div className="flex flex-wrap items-center gap-2 rounded-xl2 bg-brand-card border border-white/5 px-3 py-2 shadow-soft">
      {value.map((tag) => (
        <span
          key={tag}
          className="inline-flex items-center gap-2 px-2 py-1 text-xs rounded-full bg-brand-primary/20 border border-brand-primary/30"
        >
          {tag}
          <button
            className="opacity-70 hover:opacity-100"
            onClick={() => onChange(value.filter((t) => t !== tag))}
            aria-label={`Remove ${tag}`}
          >
            ✕
          </button>
        </span>
      ))}
      <input
        ref={ref}
        value={input}
        onChange={(e) => setInput(e.target.value)}
        onKeyDown={(e) => {
          if (e.key === "Enter" || e.key === ",") {
            e.preventDefault();
            commit();
          }
        }}
        onBlur={commit}
        placeholder={placeholder}
        className="flex-1 bg-transparent outline-none text-sm placeholder:text-brand-muted"
      />
    </div>
  );
}
