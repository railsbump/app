require "sidekiq/web"
require "sidekiq-scheduler/web"

if Rails.env.production?
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    {
      username => "SIDEKIQ_USERNAME",
      password => "SIDEKIQ_PASSWORD"
    }.map { ActiveSupport::SecurityUtils.secure_compare _1, ENV.fetch(_2) }
     .all?
  end
end

Rails.application.routes.draw do
  mount Sidekiq::Web => "sidekiq"

  get '/sitemap.xml', to: 'sitemaps#show'
  get "/robots.txt" => "static#robots"

  root "gemmies#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :gemmies, path: "gems", only: %i(show new create) do
    collection do
      get :compat_table
    end
  end
  resources :lockfiles, only: %i(new create show)
  resources :email_notifications, only: :create

  namespace :api, path: '', constraints: { subdomain: "api" } do
    resources :github_notifications, only: :create
    resources :releases, only: :create
    resources :results, only: :create
  end
end
