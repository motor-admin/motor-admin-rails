Motor::Admin.routes.draw do
  namespace 'motor', path: '' do
    get '/', to: 'ui#show'

    resources :resources, path: '/resources/:resource', only: %i[index show update create destory]
    resources :assets, param: 'filename', only: :show, format: false, constraints: {
                                     filename: %r{[^/]+}
                                   }
  end
end

Motor::Api.routes.draw do
  namespace 'motor', path: '/:resource' do
    resources :resources, path: '', only: %i[index show update create destory]
  end
end
