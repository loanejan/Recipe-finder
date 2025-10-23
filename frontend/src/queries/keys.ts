export const keys = {
    pantry: ['pantry'] as const,
    recipes: (q: string) => ['recipes', q] as const,
    recipe: (id: number) => ['recipe', id] as const,
    }