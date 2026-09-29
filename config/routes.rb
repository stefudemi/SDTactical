Rails.application.routes.draw do
  root "home#index"

  resources :products, only: [:index, :show]

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  namespace :admin do
<<<<<<< HEAD
    root "dashboard#index"
=======
    root "products#index"
>>>>>>> 27c6c25 (Add admin authentication and authorization)
    resources :products
    resources :categories
<<<<<<< HEAD
    resources :orders, only: [:index, :show, :edit, :update]
    resources :users, only: [:index, :show, :edit, :update]
=======
    resources :orders, only: [:index, :show, :update]
>>>>>>> e646093 (Complete admin categories and orders CRUD)
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :products, only: [:index, :show]
      post "login", to: "sessions#create"
      delete "logout", to: "sessions#destroy"
      get "profile", to: "profile#show"
      resources :orders, only: [:index, :show, :create]
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
