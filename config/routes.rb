Rails.application.routes.draw do
  
  devise_for :users
  resources :invoices
  resources :clients
  resources :items
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Defines the root path route ("/")
  root to: "home#index"

  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
