# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExceptionHandler, type: :controller do
  # Create an anonymous controller to include the concern
  controller(ApplicationController) do
    include ExceptionHandler

    def index
      raise ActiveRecord::RecordNotFound, 'Record not found'
    end

    def show
      raise ExceptionHandler::InvalidToken, 'Invalid token'
    end
  end

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
      get 'show' => 'anonymous#show'
    end
  end

  let(:current_user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: current_user.id) }
  before do
    @request.headers['Authorization'] = "Bearer #{token}"
  end

  describe 'rescue_from ActiveRecord::RecordNotFound' do
    before { get :index }

    it 'responds with a JSON and status code :not_found (404)' do
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)).to eq({ 'message' => 'Record not found' })
    end
  end

  describe 'rescue_from ExceptionHandler::InvalidToken' do
    before { get :show }

    it 'responds with a JSON and status code :unauthorized (401)' do
      expect(response.status).to eq(401)
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to match(/Invalid token|Nil JSON web token/)
    end
  end
end
