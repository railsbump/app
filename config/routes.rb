require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => 'sidekiq'

  root 'gemmies#index'

  resources :gemmies, path: 'gems', only: %i(show new create)
  resources :gemfiles, only: %i(new create show)
  resources :compats, only: [] do
    collection do
      get 'table'
    end
  end

  namespace :api, path: '', constraints: { subdomain: 'api' } do
    resources :releases, only: :create
    resources :travis_notifications, only: :create
  end
end
