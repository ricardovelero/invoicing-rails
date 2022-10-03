Rails.application.routes.draw do

  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :invoices
  resources :clients
  resources :items
  resources :invoices do
    post :add_item, on: :collection
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Defines the root path route ("/")
  root to: "home#index"
  get '/privacy', to: 'home#privacy'
  get '/terms', to: 'home#terms'

  get '/dashboard', to: 'dashboard#index'

  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
