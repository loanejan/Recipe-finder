export default function EmptyState({ title, hint }: { title: string; hint?: string }) {
  return (
    <div className="text-center py-20">
      <p className="text-lg">{title}</p>
      {hint && <p className="text-sm text-brand-muted mt-1">{hint}</p>}
    </div>
  );
}
