Motor::Admin.routes.draw do
  namespace 'motor', path: '' do
    resources :resources, path: '/data/:resource',
                          only: %i[index show update create destory]
    resource :schema, only: %i[show update]
    resources :assets, param: 'filename',
                       only: :show,
                       format: false,
                       constraints: { filename: /.+/ }

    get '/', to: 'ui#show'
    get '/resources/(*path)', to: 'ui#show'
  end
end

Motor::Api.routes.draw do
  namespace 'motor', path: '' do
    resources :resources, path: '/:resource',
                          only: %i[index show update create destory]
  end
end
