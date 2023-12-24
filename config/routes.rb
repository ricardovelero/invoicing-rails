# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  root 'dashboard#index'
  devise_for :users, controllers: { registrations: 'registrations' }
  resources :users
  resources :clients
  resources :items
  resources :invoices do
    resources :line_items, except: [:index]
    post :add_item, on: :collection
  end
  resources :after_register

  get '/', to: 'home#index'
  get '/privacy', to: 'home#privacy'
  get '/terms', to: 'home#terms'
  get '/regions', to: 'countries#regions'
  get '/dashboard', to: 'dashboard#index'
  get 'charts/show', as: :chart

  scope '(:locale)', locale: /es|en/ do
    resources :users
    resources :dashboard
    resources :invoices
    resources :clients
    resources :items
    root 'home#index', as: 'home_index', via: :all
  end

  localized do
    resources :users
    resources :dashboard
    resources :invoices
    resources :clients
    resources :privacy
  end

  mount LetterOpenerWeb::Engine, at: '/letter_opener'
end
