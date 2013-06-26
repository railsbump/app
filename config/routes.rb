Ready4rails4::Application.routes.draw do
  resources :rubygems, except: :destroy, path: "gems"
  root to: "rubygems#index"
end
