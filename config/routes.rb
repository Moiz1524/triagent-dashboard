Rails.application.routes.draw do
  root "vulnerabilities#index"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :vulnerabilities, only: %i[index show]

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "sessions#create"
      resources :vulnerabilities, only: %i[index create update] do
        member { patch :archive }
      end
    end
    namespace :internal do
      post "github_issues", to: "github_issues#create"
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
