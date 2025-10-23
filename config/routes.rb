Rails.application.routes.draw do
  namespace :api do
    resources :recipes, only: [:index, :show]
    resources :pantry_items, only: [:index, :create, :destroy]
  end

  root 'static#index'
  get '*path', to: 'static#index',
    constraints: ->(req) { !req.path.start_with?('/api', '/rails') }
end