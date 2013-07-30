Ready4rails4::Application.routes.draw do
  resources :rubygems, except: :destroy, path: "gems" do
    collection do
      get :search
      get "/status/:status", to: "rubygems#status", as: "status"
    end
  end

  resource  :gemfile_check, only: [:new, :create]
  get "/gemfile/new", to: redirect("/gemfile_check/new")

  root to: "rubygems#index"
end
