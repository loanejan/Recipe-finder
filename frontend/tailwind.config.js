/** @type {import('tailwindcss').Config} */
export default {
    content: ['./index.html','./src/**/*.{ts,tsx}'],
    theme: {
    extend: {
    colors: {
    brand: {
    primary: 'var(--color-primary)',
    accent: 'var(--color-accent)',
    bg: 'var(--color-bg)',
    card: 'var(--color-card)',
    text: 'var(--color-text)',
    muted: 'var(--color-muted)'
    }
    },
    boxShadow: { soft: '0 10px 30px rgba(0,0,0,0.07)' },
    borderRadius: { xl2: '1rem' }
    }
    },
    plugins: []
    }