Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }
  resources :invoices
  resources :clients
  resources :items
  resources :invoices do
    post :add_item, on: :collection
  end
  resources :after_register
  resources :contact, only: [:create]
  
  get "/privacy", to: "home#privacy"
  get "/terms", to: "home#terms"
  get "/regions", to: "countries#regions"
  get "/dashboard", to: "dashboard#index"

  scope "(:locale)", locale: /es|en/ do
    resources :dashboard
    resources :invoices
    resources :clients
    resources :items
    root "home#index", as: "home_index", via: :all
  end

  localized do
    resources :dashboard
    resources :invoices
    resources :clients
    resources :privacy
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
