############################
# Stage 1: build frontend
############################
FROM node:20 AS frontend-build

WORKDIR /frontend

# Copier uniquement le frontend pour installer les deps et builder
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm install

COPY frontend/ ./
# build frontend (adapte cette commande si ce n'est pas `npm run build`)
RUN npm run build

# À la fin de ce stage, on suppose que les assets finaux statiques sont dans /frontend/dist
# (ou /frontend/build selon ton outil). Ajuste le chemin plus bas si différent.


############################
# Stage 2: build Rails app
############################
FROM ruby:3.2

# 1. Dépendances système + Postgres client libs + etc.
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    postgresql-client \
    libpq-dev \
    libffi-dev \
    libyaml-dev \
    zlib1g-dev \
    git \
    curl \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Gems Ruby
COPY Gemfile Gemfile.lock ./
RUN bundle install

# 3. Copier tout le code Rails
COPY . .

# 4. Amener le build frontend dans Rails
#    Ici je suppose que tu veux servir le front via Rails en prod
#    et que Rails va servir des fichiers statiques depuis public/.
#    Si ton front build sort ailleurs que `dist/`, modifie la source.
COPY --from=frontend-build /frontend/dist /app/public

# 5. Précompile les assets Rails
ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV SECRET_KEY_BASE_DUMMY=1
RUN bundle exec rails assets:precompile

# 6. Expose port
EXPOSE 8080

# 7. Commande de lancement
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "8080", "-e", "production"]
