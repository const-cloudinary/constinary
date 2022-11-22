Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pictures#index"

  get "/pictures", to: "pictures#index"

  resources :transformations

  match "*path", to: "pictures#transform", via: :get
end
