Ready4rails4::Application.routes.draw do
  resources :rubygems, except: :destroy, path: "gems"
  resource  :gemfile_check, only: [:new, :create]

  root to: "rubygems#index"
end
