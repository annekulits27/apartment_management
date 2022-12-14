Rails.application.routes.draw do

  devise_for :users, :controllers => { registrations: 'users/registrations' }, :path => '', :path_names => { :sign_in => "portal/login", :sign_up => "portal/register" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  unauthenticated :user do
    root 'home#index', as: :unauthenticated_root
  end

  authenticated :user do
    root 'dashboards#index', as: :authenticated_root
  end

  resources :users do
    post :lock, on: :member
    post :unlock, on: :member
  end

  resources :tenants, only: [:index, :show], shallow: true do
    post :activate, on: :member
    resources :bookings, shallow: true do
      post :deactivate, on: :member
      resources :invoices, only: [:new, :create], shallow: true do
        resource :payment, only: [:new, :create]
      end
    end
  end

  resources :concerns do
    get :close, on: :member
    post :reopen, on: :member
  end

  resources :payments, only: [:index, :show, :update] do
    get :approve, on: :member
  end

  resources :invoices, only: [:index, :show, :update] do
    get :active, on: :collection
  end

  resources :announcements do
    post :archive, on: :member
    post :republish, on: :member
  end
  resources :dashboard, only: [:index]
  resources :inquiries do
    post :assists, on: :member
  end
  resources :expenses
  resources :branches, only: [:index, :show] do
    resources :rooms, only: [:index, :show]
  end

  get '/rooms/available' => 'rooms#available', as: 'available_rooms'

  resource :profile, only: [:show, :edit, :update] do
    get 'purge_avatar', on: :collection
  end
  resolve('Profile') { [:profile] }

end
