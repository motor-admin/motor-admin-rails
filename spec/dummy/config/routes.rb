# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  mount Motor::Admin => '/'

  resources :notes, only: %i[create]
  resources :orders, only: %i[show create update] do
    resource :cancel, only: %i[create], controller: 'orders_cancel'
  end
end
