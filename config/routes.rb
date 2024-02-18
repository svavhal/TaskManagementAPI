# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'register', to: 'registration#register'
      post 'login', to: 'registration#login'

      resources :tasks, only: %i[index show create update destroy] do
        member do
          patch 'mark_completed'
        end
      end
    end
  end
end
