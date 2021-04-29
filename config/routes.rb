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
      resources :resource_methods, only: %i[show], param: 'resource'
      resources :dashboards, only: %i[index show create update destroy]
      resources :forms, only: %i[index show create update destroy]
      resources :alerts, only: %i[index show create update destroy]
      resources :active_storage_attachments, only: %i[create], path: 'data/active_storage__attachments'
      resource :schema, only: %i[show update]
      resources :resources, path: '/data/:resource',
                            only: %i[index show update create destroy],
                            controller: 'data' do
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

    scope as: 'ui' do
      with_options controller: 'ui' do
        resources :data, only: %i[index show],
                         param: 'path',
                         constraints: { path: /.+/ }
        resources :reports, only: %i[index show]
        resources :queries, only: %i[index show]
        resources :dashboards, only: %i[index show]
        resources :alerts, only: %i[index show]
        resources :forms, only: %i[index show]
      end
    end
  end
end

Motor::Api.routes.draw do
  namespace :motor, path: '' do
    resources :resources, path: '/:resource',
                          only: %i[index show update create destroy],
                          controller: 'data' do
      put '/:method', to: 'data#execute'
      resources :association, path: '/:association',
                              only: %i[index create],
                              controller: 'data'
    end
  end
end
