# frozen_string_literal: true

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

  if asset_host = ENV["ASSET_HOST"]
    get ":sitemap", sitemap: /sitemap[A-Za-z\d.]*/, to: redirect { "#{asset_host}#{_2.path}" }
  end

  root "gemmies#index"

  get :health, controller: "application"

  resources :gemmies, path: "gems", only: %i(show new create) do
    collection do
      get :compat_table
    end
  end
  resources :lockfiles, only: %i(new create show)
  resources :email_notifications, only: :create

  namespace :api, path: '', constraints: { subdomain: "api" } do
    resources :releases, only: :create
    resources :github_notifications, only: :create
  end
end
