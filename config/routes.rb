# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  # root 'home#index', as: 'home_index', via: :all
  devise_for :users, controllers: { registrations: 'registrations' }
  resources :users
  resources :clients
  resources :items
  resources :invoices do
    resources :line_items, except: [:index]
    post :add_item, on: :collection
  end
  resources :after_register

  get '/privacy', to: 'home#privacy'
  get '/terms', to: 'home#terms'
  get '/regions', to: 'countries#regions'
  get '/dashboard', to: 'dashboard#index'
  get 'charts/show', as: :chart

  scope '/:locale', locale: /#{I18n.available_locales.join('|')}/ do
    resources :users
    resources :dashboard
    resources :invoices
    resources :clients
    resources :items
  end

  localized do
    resources :users
    get '/invoices', to: 'invoices#index', as: :invoices
    get '/invoices/new', to: 'invoices#new', as: :new_invoice
    get '/invoices/:id', to: 'invoices#show', as: :show_invoice
    get '/invoices/edit/:id', to: 'invoices#edit', as: :edit_invoice
    get '/clients', to: 'clients#index', as: :clients
    get '/clients/new', to: 'clients#new', as: :new_client
    get '/clients/:id', to: 'clients#show', as: :show_client
    get '/clients/edit/:id', to: 'clients#edit', as: :edit_client
    get '/items', to: 'items#index', as: :items
    get '/items/new', to: 'items#new', as: :new_item
    get '/items/:id', to: 'items#show', as: :show_item
    get '/items/edit/:id', to: 'items#edit', as: :edit_item
    get '/dashboard', to: 'dashboard#index', as: :dashboard
    get '/privacy', to: 'home#privacy', as: :privacy
  end

  root 'dashboard#index'
  mount LetterOpenerWeb::Engine, at: '/letter_opener'
end
