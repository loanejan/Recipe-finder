import { Link, Route, Routes } from "react-router-dom";
import RecipesPage from "./pages/RecipesPage";
import RecipePage from "./pages/RecipePage";
import NotFoundPage from "./pages/NotFoundPage";
import Logo from "./components/Logo";

export default function App() {
  return (
    <div className="min-h-screen">
      <header className="sticky top-0 z-50 backdrop-blur bg-brand-bg/70 border-b border-white/5">
        <div className="max-w-5xl mx-auto px-4 py-3 flex items-center gap-4">
          <Link to="/" className="flex items-center gap-2">
            <Logo />
            <span className="font-semibold tracking-tight">PennyLane Recipes</span>
          </Link>
          <nav className="ml-auto flex items-center gap-4 text-sm text-brand-muted">
            <Link to="/" className="hover:text-brand-text">
              Recipes
            </Link>
          </nav>
        </div>
      </header>
      <main className="max-w-5xl mx-auto px-4 py-6">
        <Routes>
          <Route path="/" element={<RecipesPage />} />
          <Route path="/recipes/:id" element={<RecipePage />} />
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </main>
      <footer className="max-w-5xl mx-auto px-4 py-10 text-center text-xs text-brand-muted">
        Built with React + TS + React Query + Tailwind
      </footer>
    </div>
  );
}
