Rails.application.routes.draw do

  post 'carts/add'
  get 'carts/paypal_checkout'
  get 'carts/success'
  get 'carts/cancel'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, :controllers => { :registrations => "users/registrations", :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'user/:username' => "users/registrations#profile", :as => :profile
    match 'users/finish_registration' => 'users/registrations#finish_registration', via: [:get, :patch], :as => :finish_registration
  end

  resources :sheets do
    collection do
      get 'autocomplete'
    end

    member do
      get 'download'
      get 'like'
      post 'flag'
      get 'restore'
    end
  end

  resources :assets, only: [:create, :destroy]
  get 'assets/:id/download' => 'assets#download', as: 'download_asset'

  get 'search' => 'sheets#search'

  get 'instruments' => 'sheets#instruments'
  get 'instrument/:slug' => 'sheets#by_instrument', as: 'instrument'

  get 'genres' => 'sheets#genres'
  get 'genre/:slug' => 'sheets#by_genre', as: 'genre'

  get 'composers' => 'sheets#composers'
  get 'composer/:slug' => 'sheets#by_composer', as: 'composer'

  get 'sources' => 'sheets#sources'
  get 'source/:slug' => 'sheets#by_source', as: 'source'

  root 'sheets#index'
  get '/about', to: 'pages#about'
  get '/terms', to: 'pages#terms'
  get '/privacy', to: 'pages#privacy'
end
