Rails.application.routes.draw do
  root "toppages#index"
  
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  
  get "signup", to: "users#new"
  
  resources :users, except: [:new, :destroy] do
    member do
      get :followings
      get :followers
    end
  end
  
  resources :messages, only: [:create, :destroy]
  resources :relationships, only: [:create, :destroy]
end
