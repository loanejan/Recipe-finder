export default function Loader({ label = "Loading…" }: { label?: string }) {
  return (
    <div className="grid place-items-center py-20 text-brand-muted">
      <div className="h-8 w-8 animate-spin rounded-full border-2 border-brand-primary border-t-transparent" />
      <p className="mt-3 text-sm">{label}</p>
    </div>
  );
}
