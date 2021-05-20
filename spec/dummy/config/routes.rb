# frozen_string_literal: true

Rails.application.routes.draw do
  mount Motor::Admin => '/'

  resources :orders, only: [] do
    resource :cancel, only: %i[create], controller: 'orders_cancel'
  end
end
