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

  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    resources :users
    resources :dashboard
    resources :invoices
    resources :clients
    resources :items
  end

  localized do
    resources :users
    resources :dashboard
    resources :invoices, path_names: { new: 'new_invoice', edit: 'edit_invoice' }
    resources :clients, path_names: { new: 'new_client', edit: 'edit_client' }
    resources :items, path_names: { new: 'new_item', edit: 'edit_item' }
    resources :privacy
    root 'dashboard#index'
  end

  mount LetterOpenerWeb::Engine, at: '/letter_opener'
end
