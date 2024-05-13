class UsersController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource
    
    def qas
        @qas = User.qas
        render json: UserSerializer.new(@qas, fields: { user: [:id, :name] }).serializable_hash[:data].map { |item| item[:attributes] }
      end
    
      def developers
        @developers = User.developers
        render json: UserSerializer.new(@developers, fields: { user: [:id, :name] }).serializable_hash[:data].map { |item| item[:attributes] }
      end
end
