Rails.application.routes.draw do
  root 'gemmies#index'

  resources :gemmies, path: 'gems', only: :show
  resources :gemfiles, only: %i(new create show)

  namespace :api, path: '', constraints: { subdomain: 'api' } do
    resources :releases, only: :create
  end
end
