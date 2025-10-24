# 🍳 Pennylane Technical Test — Recipe Finder

> A small full-stack web application that helps users find relevant recipes based on the ingredients they already have at home.

---

## 👋 Context & Approach

This project was completed as part of the **Software Engineer Technical Test @ Pennylane**.  
The goal was to **design and implement a prototype** that focuses on **product thinking, simplicity, and user experience**, rather than pure styling or feature volume.

My priorities were:
- Keep the UX frictionless — one simple flow: *add → search → cook*.
- Design a clean and minimal API structure (`/api/recipes`, `/api/pantry_items`).
- Deliver something realistic and demo-ready (local or hosted).

---

## 🎯 Objective

> Create an application that suggests recipes based on the ingredients the user already has.

Users can:
1. Manage their **pantry items** (ingredients they have at home)
2. Get **recipe recommendations** that match their pantry
3. Open a **recipe detail page** with title, yield, and full ingredients list

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

## 💡 Product Philosophy

Rather than building many features, I focused on **a coherent end-to-end flow**:

1. **User starts empty** → adds ingredients they own  
2. **Backend filters recipes** based on match ratio  
3. **UI displays sorted, relevant recipes** with match %, time, and yield  
4. **Fallbacks everywhere** (images, empty states) to ensure a smooth experience

> Every step should “just work” — even if the data is imperfect or incomplete.

---

## 📚 User Stories

### 🧺 1. Manage my pantry
> As a user, I can add or remove ingredients to keep track of what I have at home.

**Endpoints**
```
GET    /api/pantry_items
POST   /api/pantry_items
DELETE /api/pantry_items/:id
```

---

### 🥣 2. Find recipes I can cook
> As a user, I can see recipes that best match the ingredients in my pantry.

**Logic**
- Each recipe’s “match ratio” = number of matching ingredients ÷ total ingredients.
- Sorted by best match first.

**Endpoint**
```
GET /api/recipes
```

---

### 📖 3. View recipe details
> As a user, I can open a recipe to see details (title, time, yield, ingredients).

**Endpoint**
```
GET /api/recipes/:id
```

---

## 🧠 AI Tools Disclosure

I used **ChatGPT (GPT-5)** as an assistant to:
- Speed up boilerplate setup for Rails + Vite integration
- Debug PostgreSQL setup and migrations
- Brainstorm a clean API structure
- Format this README

All AI-generated code and text were **reviewed, edited, and validated** by me.  
Every technical choice (schema, routes, data logic) was implemented manually.

> My approach to AI is pragmatic: it’s a *pair programmer*, not a substitute for understanding.

---

## 💾 Dataset

The recipes come from the dataset provided by Pennylane’s prompt:  
English-language recipes scraped from AllRecipes.com using `recipe-scrapers`.

**Download:**
```bash
wget https://pennylane-interviewing-assets-20220328.s3.eu-west-1.amazonaws.com/recipes-en.json.gz   && gzip -dc recipes-en.json.gz > recipes-en.json
```

Then import via:
```bash
bin/rails data:import
```

---

## 🖼️ Image handling

Some recipe images are hosted on Meredith’s CDN (`imagesvc.meredithcorp.io`),  
which **blocks hotlinking from non-AllRecipes domains** (returns 400).

To keep a consistent experience, a **local fallback image** is used:

- File: `frontend/public/placeholder-recipe.jpg`
- React `onError` handler automatically replaces any broken image with this fallback
- Displayed with soft shadows and subtle opacity, to match the UX palette

> This prevents broken-image icons and ensures a graceful degradation in both dev and production.

---

## 🧱 Project structure

```
pennylane_technical_test/
│
├── app/
│   ├── controllers/
│   │   ├── api/
│   │   │   ├── recipes_controller.rb
│   │   │   └── pantry_items_controller.rb
│   │   └── static_controller.rb
│   ├── models/
│   └── views/ (empty – API only)
│
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   └── hooks/
│   ├── public/
│   │   └── placeholder-recipe.jpg
│   ├── vite.config.ts
│   └── package.json
│
├── lib/tasks/frontend.rake   # Rake task to build + copy frontend
└── db/
    └── migrations/
```

---

## ⚙️ Setup

### 1️⃣ Dependencies
- Ruby ≥ 3.2  
- Node ≥ 18  
- PostgreSQL ≥ 14

### 2️⃣ Install
```bash
bundle install
cd frontend && npm install
```

### 3️⃣ DB setup
```bash
bin/rails db:create db:migrate
bin/rails data:import
```

### 4️⃣ Development
#### Mode A — Hot reload (best for dev)
```bash
# Terminal 1
bin/rails s

# Terminal 2
cd frontend
npm run dev
```
→ Frontend: http://localhost:5173  
→ API: http://localhost:3000/api

#### Mode B — Production preview
```bash
bin/rake frontend:build
bin/rails s
```
→ Visit http://localhost:3000

---

## 🧭 Rake Tasks

| Command | Description |
|----------|--------------|
| `bin/rake frontend:build` | Build & copy the React frontend to `/public` |
| `bin/rails data:import` | Load and normalize dataset |
| `bin/rails db:create db:migrate` | Prepare DB schema |

---

## 🎨 Design choices

- **Soft purple & indigo tones** (inspired by Pennylane’s visual identity)
- **Minimal UI** → focus on clarity and hierarchy
- **Responsive layout** (grid-based, no complex breakpoints)
- **Typography**: clean sans-serif for readability

> The UX goal was: *pleasant, clear, and non-distracting*.

---

## 🚀 Improvements if this were a real product

- [ ] Add persistence of pantry via user login
- [ ] Improve search UX (autocomplete, fuzzy matching)
- [ ] Allow “filter by prep time” or “vegetarian”
- [ ] Cache recipe list per user
- [ ] Deploy with continuous build (GitHub Actions + Fly.io)

---

## ✍️ Author

**Loane Jan**  
Fullstack Developer — Product-minded engineer who loves combining clean UX with pragmatic backend logic.  
Built with ❤️ using Rails, React, and a bit of curiosity.
