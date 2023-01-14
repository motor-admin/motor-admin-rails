# frozen_string_literal: true

Motor::Admin.routes.draw do
  namespace :motor, path: '' do
    mount ActionCable.server => '/cable', as: :cable if defined?(ActionCable)

    scope 'api', as: :api do
      resources :run_queries, only: %i[show create]
      resources :send_alerts, only: %i[create]
      resources :auth_tokens, only: %i[create]
      resources :queries, only: %i[index show create update destroy]
      resources :tags, only: %i[index]
      resources :configs, only: %i[index create]
      resources :resources, only: %i[index create]
      resources :resource_methods, only: %i[show], param: 'resource'
      resources :resource_default_queries, only: %i[show], param: 'resource'
      resources :schema, only: %i[index show], param: 'resource'
      resources :dashboards, only: %i[index show create update destroy]
      resource :run_api_request, only: %i[show create]
      resource :run_graphql_request, only: %i[create]
      resources :api_configs, only: %i[index create destroy]
      resources :forms, only: %i[index show create update destroy]
      resources :notes, only: %i[index show create update destroy]
      resources :note_tags, only: %i[index]
      resources :users_for_autocomplete, only: %i[index]
      resources :notifications, only: %i[index update]
      resources :reminders, only: %i[create destroy]
      resources :alerts, only: %i[index show create update destroy]
      resources :icons, only: %i[index]
      resources :active_storage_attachments, only: %i[create], path: 'data/active_storage__attachments'
      resources :audits, only: %i[index]
      resource :session, only: %i[show destroy]
      resources :slack_conversations, only: %i[index]
      resources :resources, path: '/data/:resource',
                            only: %i[index show update create destroy],
                            controller: 'data',
                            constraints: { id: %r{[^/]+} } do
        put '/:method', to: 'data#execute'
        resources :association, path: '/:association',
                                only: %i[index create],
                                controller: 'data'
      end
    end

    resources :assets, param: 'filename',
                       only: :show,
                       format: false,
                       constraints: { filename: /.+/ }

    get '/', to: 'ui#show'

    scope as: :ui do
      get '/data(/*path)', to: 'ui#index', as: :data

      with_options controller: 'ui' do
        resources :notifications, only: %i[index]
        resources :reports, only: %i[index show]
        resources :queries, only: %i[index show new]
        resources :dashboards, only: %i[index show new]
        resources :alerts, only: %i[index show new]
        resources :forms, only: %i[index show new]
      end
    end
  end
end
