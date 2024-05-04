class ApplicationController < ActionController::API
    rescue_from CanCan::AccessDenied do |exception|
        render json: { error: "Access denied: #{exception.message}" }, status: :forbidden
      end
end
