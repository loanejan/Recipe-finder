# 🍳 Pennylane Technical Test — Recipe Finder

> A small full-stack web application that helps users find relevant recipes based on the ingredients they already have at home.

---

## 👋 Context & Approach

This project was completed as part of the **Software Engineer Technical Test @ Pennylane**.  
The goal was to **design and implement a prototype** that focuses on **product thinking, simplicity, and user experience**, rather than pure styling or feature volume.

My priorities were:
- Keep the UX frictionless — one simple flow: *add → search → cook*.
- Design a clean and minimal API structure.
- Deliver something realistic and demo-ready (local and hosted).

---

## 🧩 Architecture Overview

| Layer | Stack | Notes |
|-------|--------|-------|
| **Backend** | Ruby on Rails 7 (API mode) | Fast to iterate, clean JSON responses |
| **Database** | PostgreSQL | Perfect for joins & filtering logic |
| **Frontend** | React + TypeScript + Vite | Lightweight and fast dev setup |
| **Styling** | Tailwind CSS | Modern utility-based approach |
| **Data fetching** | React Query | Caching & request management |
| **Deployment** | Fly.io / Local | Simple single-command setup |

---

# 🍽️ Recipe Finder App

## 🧩 User Stories

### 1. Search for recipes based on available ingredients
**As a user**, I want to enter the ingredients I currently have at home **so that I can find the most relevant recipes I can cook with them**.

#### ✅ Acceptance Criteria
- I can input one or multiple ingredients (e.g., “pasta, eggs, tuna”).
- The application returns a list of recipes.
- Recipes are **sorted by relevance** — recipes that use the most of my available ingredients appear first.
- Each recipe in the list shows:
  - The recipe name
  - An image (if available)
  - The number of matching ingredients
  - The time to prepare the recipe
- If no recipe matches, a message like “No recipes found with these ingredients” is displayed.

#### 💡 Value
This is the core feature — turning what’s already in the fridge into actual meal ideas.

---

### 2. View recipe details
**As a user**, I want to open a recipe from the results list **to see its full details and know how to prepare it**.

#### ✅ Acceptance Criteria
- When I click on a recipe, I am redirected to a **recipe detail page**.
- The detail page displays:
  - Recipe title  
  - Estimated preparation time  
  - Full list of ingredients
- A “Back” button allows me to return to the previous search results page.

#### 💡 Value
Allows the user to take action — from discovery to cooking — without leaving the app.

---

### 3. Preserve entered ingredients when navigating back
**As a user**, I want my entered ingredients and search results **to remain visible when I navigate back from a recipe detail page**, so I don’t have to re-enter them.

#### ✅ Acceptance Criteria
- After performing a search, if I open a recipe and then go back:
  - My previously entered ingredients remain in the input field.
  - The search results list remains visible.
- This behavior persists even if I open several recipes consecutively.

#### 💡 Value
Improves user experience by reducing friction — allows easy recipe comparison without retyping the ingredient list.

---

## 🧠 AI Tools Disclosure

I used **ChatGPT (GPT-5)** as an assistant to:
- Speed up boilerplate setup for Rails + Vite integration
- Debug PostgreSQL setup and migrations
- Deploy with fly.io
- Speed up my frontend files in React
- Format this README

All AI-generated code and text were **reviewed, edited, and validated** by me.  
Every technical choice (schema, routes, data logic) was implemented manually.

---

## 🖼️ Image handling

Some recipe images are hosted on Meredith’s CDN (`imagesvc.meredithcorp.io`),  
which **blocks hotlinking from non-AllRecipes domains**.

To keep a consistent experience, a **local fallback image** is used:

- File: `frontend/public/placeholder-recipe.jpg`
- React `onError` handler automatically replaces any broken image with this fallback

> This prevents broken-image icons and ensures a graceful degradation in both dev and production.

---

## ✍️ Author

**Loane Jan**  
Fullstack Developer
