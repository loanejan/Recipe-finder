FROM ruby:3.2

# Installer dépendances système
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libffi-dev \
    libyaml-dev \
    zlib1g-dev \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Installe les gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copie le reste du code
COPY . .

# Expose le port attendu par Fly
EXPOSE 8080

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "8080", "-e", "production"]

