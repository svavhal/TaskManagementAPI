# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  class InvalidToken < StandardError; end

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ message: e.message }, :not_found)
    end
    rescue_from ExceptionHandler::InvalidToken do |e|
      json_response({ message: e.message }, :unauthorized)
    end
  end

  private

  def json_response(object, status = :ok)
    render json: object, status: status
  end
end
