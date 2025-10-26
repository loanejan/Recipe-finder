source "https://rubygems.org"

gem "rails", "~> 8.1.0"
gem "propshaft"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "image_processing", "~> 1.2"

group :development, :test do
  gem "pg", "~> 1.1"

  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem "web-console"
  gem "rspec-rails"
end

group :test do
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem "capybara"
  gem "selenium-webdriver"
  gem "rspec-rails"
end

group :production do
  gem "sqlite3", ">= 2.1"
end

gem "rubocop", "~> 1.81", group: :development
gem "rubocop-rails", "~> 2.33", group: :development
gem "dockerfile-rails", ">= 1.7", group: :development
