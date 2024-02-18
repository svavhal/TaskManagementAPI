# frozen_string_literal: true

module Api
  module V1
    class RegistrationController < ApplicationController
      protect_from_forgery with: :null_session
      skip_before_action :authenticate_request, only: %i[login register]
      # POST /register
      def register
        user = User.new(user_params)
        if user.save
          render json: { status: 'User created successfully' }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :bad_request
        end
      end

      # POST /login
      def login
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id)
          time = Time.now + 24.hours.to_i
          render json: { token: token, exp: time.strftime('%m-%d-%Y %H:%M'), username: user.email }, status: :ok
        else
          render json: { error: 'unauthorized' }, status: :unauthorized
        end
      end

      private

      def user_params
        params.permit(:email, :password, :password_confirmation)
      end
    end
  end
end
