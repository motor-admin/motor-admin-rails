# frozen_string_literal: true

Motor::Admin.routes.draw do
  namespace :motor, path: '' do
    scope 'api', as: 'api' do
      resources :run_queries, only: %i[show create]
      resources :send_alerts, only: %i[create]
      resources :queries, only: %i[index show create update destroy]
      resources :tags, only: %i[index]
      resources :configs, only: %i[index create]
      resources :resources, only: %i[index create]
      resources :dashboards, only: %i[index show create update destroy]
      resources :alerts, only: %i[index show create update destroy]
      resource :schema, only: %i[show update]
      resources :resources, path: '/data/:resource',
                            only: %i[index show update create destroy],
                            controller: 'data' do
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
    get '/data/(*path)', to: 'ui#show'

    scope as: 'ui' do
      with_options controller: 'ui' do
        resources :browse, only: %i[index]
        resources :queries, only: %i[index show]
        resources :dashboards, only: %i[index show]
        resources :tables, only: %i[index]
        resources :alerts, only: %i[index show]
      end
    end
  end
end

Motor::Api.routes.draw do
  namespace :motor, path: '' do
    resources :resources, path: '/:resource',
                          only: %i[index show update create destroy],
                          controller: 'data' do
      resources :association, path: '/:association',
                              only: %i[index create],
                              controller: 'data'
    end
  end
end
