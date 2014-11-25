Rails.application.routes.draw do
  mount PgHero::Engine, at: "pghero"


  get 'upgrade/:membership' => 'upgrades#purchase', as: 'upgrades_purchase'


  post 'checkout' => 'orders#checkout'
  get 'orders/success/:tracking_id', to:'orders#success', as: 'orders_success'
  get 'orders/cancel'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, :controllers => { :registrations => "users/registrations", :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'user/:username' => "users/registrations#profile", :as => :user_profile
    get 'user/:username/favorites' => "users/registrations#favorites", :as => :user_favorites
    match 'users/finish_registration' => 'users/registrations#finish_registration', via: [:get, :patch], :as => :finish_registration
    get 'private_sheets' => "users/registrations#private_sheets", :as => :user_private_sheets
    get 'sales' => "users/registrations#sales", :as => :user_sales
    get 'purchases' => "users/registrations#purchases", :as => :user_purchases
    get 'trash' => "users/registrations#trash", :as => :user_trash

    get '/settings' => 'users/registrations#edit', :as => :user_settings
  end

  resources :sheets do
    collection do
      get 'autocomplete'
    end

    member do
      get 'favorites'
      get 'download'
      post 'favorite'
      get 'report'
      post 'flag'
      post 'restore'
    end
  end

  get 'upload' => 'sheets#new', as: 'sheet_upload'

  resources :assets, only: [:create, :destroy]
  get 'assets/:id/download' => 'assets#download', as: 'download_asset'

  get 'best_sellers' => 'sheets#best_sellers'
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
  get '/help', to: 'pages#faq', as: 'faq'
  get '/terms', to: 'pages#terms'
  get '/privacy', to: 'pages#privacy'
  get '/upgrade', to: 'pages#upgrade'
end
