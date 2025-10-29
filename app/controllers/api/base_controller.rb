module Api
  class BaseController < ActionController::API
    # Force the default JSON format to avoid 406 errors
    before_action -> { request.format = :json }
  end
end