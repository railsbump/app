Ready4rails4::Application.routes.draw do
  resources :rubygems, except: :destroy, path: "gems" do
    collection do
      get 'gemfile'
      post 'checkgemfile'
    end
  end
  root to: "rubygems#index"
end
