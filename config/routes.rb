Rails4ready::Application.routes.draw do
  resources :gems, except: :destroy
  root to: "gems#index"
end
