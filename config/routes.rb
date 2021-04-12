# frozen_string_literal: true

Motor::Admin.routes.draw do
  namespace :motor, path: '' do
    scope 'api' do
      resources :run_queries, only: %i[show create]
      resources :queries, only: %i[index show create update destroy]
      resources :tags, only: %i[index]
      resources :configs, only: %i[index create]
      resources :resource_configs, only: %i[index create], controller: 'resources'
      resources :dashboards, only: %i[index show create update destroy]
      resource :schema, only: %i[show update]
    end

    resources :resources, path: '/data/:resource',
                          only: %i[index show update create destroy],
                          controller: 'data' do
      resources :association, path: '/:association',
                              only: %i[index create],
                              controller: 'data'
    end

    resources :assets, param: 'filename',
                       only: :show,
                       format: false,
                       constraints: { filename: /.+/ }

    get '/', to: 'ui#show'
    get '/resources/(*path)', to: 'ui#show'

    with_options controller: 'ui' do
      resources :queries, only: %i[index show]
      resources :dashboards, only: %i[index show]
      resources :reports, only: %i[index show]
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
