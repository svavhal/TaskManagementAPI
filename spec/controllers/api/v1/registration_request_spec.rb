# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RegistrationController, type: :controller do
  describe 'POST #register' do
    let(:user_params) { { email: 'user@example.com', password: 'password', password_confirmation: 'password' } }

    context 'when user is successfully created' do
      it 'returns a created status and success message' do
        post :register, params: user_params

        expect(response).to have_http_status(:created)
        expect(json['status']).to eq('User created successfully')
      end
    end

    context 'when user is not created due to validation errors' do
      before do
        # Simulate the case where user cannot be saved due to validation errors
        allow_any_instance_of(User).to receive(:save).and_return(false)
        allow_any_instance_of(User).to receive_message_chain(:errors,
                                                             :full_messages).and_return(['Password is too short'])
      end

      it 'returns a bad request status with error messages' do
        post :register, params: user_params

        expect(response).to have_http_status(:bad_request)
        expect(json['errors']).to include('Password is too short')
      end
    end
  end

  describe 'POST #login' do
    let(:user_credentials) { { email: 'user@example.com', password: 'password' } }
    let!(:user) { User.create(user_credentials.merge(password_confirmation: 'password')) }

    context 'when credentials are correct' do
      it 'returns an ok status with token and username' do
        allow(controller).to receive(:encode).and_return('sometoken123')

        post :login, params: user_credentials

        expect(response).to have_http_status(:ok)
        expect(json).to include('token', 'exp', 'username')
      end
    end

    context 'when credentials are incorrect' do
      it 'returns an unauthorized status' do
        wrong_credentials = { email: 'user@example.com', password: 'wrongpassword' }

        post :login, params: wrong_credentials

        expect(response).to have_http_status(:unauthorized)
        expect(json['error']).to eq('unauthorized')
      end
    end
  end
end

def json
  JSON.parse(response.body)
end
