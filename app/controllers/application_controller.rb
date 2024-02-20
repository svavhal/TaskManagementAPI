# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_request
  include JsonWebToken
  include ExceptionHandler

  private

  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    decoded = JsonWebToken.decode(header)
    @current_user = User.find(decoded[:user_id])
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end
end
