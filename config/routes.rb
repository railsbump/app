Ready4rails4::Application.routes.draw do
  get "/search", to: "rubygems#search", as: "search"

  resources :rubygems, except: [:destroy, :edit, :update], path: "gems" do
    collection {
      get "/status/:status", to: "rubygems#statuses", as: "status"
    }
  end


  resource  :gemfile_check, only: [:new, :create]
  get "/gemfile/new", to: redirect("/gemfile_check/new")

  root to: "rubygems#index"
end
