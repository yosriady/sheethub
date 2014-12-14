Rails.application.routes.draw do
  get 'upgrade/purchase/:membership' => 'subscriptions#purchase', as: 'subscriptions_purchase'
  post 'upgrade/checkout/:membership' => 'subscriptions#checkout', as: 'subscriptions_checkout'
  get 'upgrade/cancel' =>  'subscriptions#cancel', as: 'subscriptions_cancel'
  get 'upgrade/success' =>  'subscriptions#success', as: 'subscriptions_success'
  get 'downgrade/:membership' =>  'subscriptions#downgrade', as: 'subscriptions_downgrade'

  # Sheet Purchase Routes
  post 'checkout' => 'orders#checkout'
  get 'orders/success/:tracking_id', to:'orders#success', as: 'orders_success'
  get 'orders/cancel'
  # End of Sheet Purchase Routes

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, :controllers => { :registrations => "users/registrations", :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do

    get '/' => 'sheets#index', :constraints => { :subdomain => 'www' }
    get '/' => 'users/registrations#profile', :constraints => { :subdomain => /.+/ }, :as => :user_profile
    get '/favorites' => 'sheets#index', :constraints => { :subdomain => 'www' }
    get '/favorites' => 'users/registrations#favorites', :constraints => { :subdomain => /.+/ }, :as => :user_favorites

    # get 'user/:username' => "users/registrations#profile", :as => :user_profile
    # get 'user/:username/favorites' => "users/registrations#favorites", :as => :user_favorites
    match 'users/finish_registration' => 'users/registrations#finish_registration', via: [:get, :patch], :as => :finish_registration
    get 'dashboard' => "users/registrations#dashboard", :as => :user_dashboard
    get 'private-sheets' => "users/registrations#private_sheets", :as => :user_private_sheets
    get 'sales' => "users/registrations#sales", :as => :user_sales
    get 'library' => "users/registrations#library", :as => :user_library
    get 'trash' => "users/registrations#trash", :as => :user_trash

    get '/settings' => 'users/registrations#edit', :as => :user_settings
    get '/settings/membership' => 'users/registrations#edit_membership', :as => :user_membership_settings
    get '/settings/password' => 'users/registrations#edit_password', :as => :user_password_settings
    patch '/settings/password' => 'users/registrations#update_password', :as => :user_password_update
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

  resources :assets, only: [:create, :destroy]
  get 'assets/:id/download' => 'assets#download', as: 'download_asset'

  root 'sheets#index'
  get 'browse' => 'sheets#index', as: 'browse'
  get 'upload' => 'sheets#new', as: 'sheet_upload'
  get 'search' => 'sheets#search'
  get 'best-sellers' => 'sheets#best_sellers'
  get 'community-favorites' => 'sheets#community_favorites'

  get 'instruments' => 'sheets#instruments'
  get 'instrument/:slug' => 'sheets#by_instrument', as: 'instrument'

  get 'genres' => 'sheets#genres'
  get 'genre/:slug' => 'sheets#by_genre', as: 'genre'

  get 'composers' => 'sheets#composers'
  get 'composer/:slug' => 'sheets#by_composer', as: 'composer'

  get 'sources' => 'sheets#sources'
  get 'source/:slug' => 'sheets#by_source', as: 'source'

  get '/help', to: 'pages#faq', as: 'faq'
  get '/terms-of-service', to: 'pages#terms', as: 'terms'
  get '/privacy-policy', to: 'pages#privacy', as: 'privacy'
  get '/community-guidelines', to: 'pages#community_guidelines'
  get '/upgrade', to: 'pages#upgrade'
end
