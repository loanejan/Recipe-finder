module Api
  class BaseController < ActionController::API
    # Forcer le format JSON par défaut pour éviter les 406
    before_action -> { request.format = :json }
  end
end