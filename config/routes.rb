# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq-scheduler/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "sidekiq"

  root "gemmies#index"

  resources :gemmies, path: "gems", only: %i(show new create)
  resources :lockfiles, only: %i(new create show)
  resources :email_notifications, only: :create

  namespace :api, path: '', constraints: { subdomain: "api" } do
    resources :releases, only: :create
    resources :github_notifications, only: :create
  end
end
