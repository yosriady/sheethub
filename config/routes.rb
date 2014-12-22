Rails.application.routes.draw do
  defaults subdomain: 'www' do
    get "/email_processor", to: proc { [200, {}, ["OK"]] }, as: "mandrill_head_test_request"

    get 'upgrade/purchase/:membership', to: 'subscriptions#purchase', as: 'subscriptions_purchase'
    post 'upgrade/checkout/:membership', to: 'subscriptions#checkout', as: 'subscriptions_checkout'
    get 'upgrade/cancel', to: 'subscriptions#cancel', as: 'subscriptions_cancel'
    get 'upgrade/success', to: 'subscriptions#success', as: 'subscriptions_success'
    get 'downgrade/:membership', to: 'subscriptions#downgrade', as: 'subscriptions_downgrade'

    # Sheet Purchase Routes
    post 'checkout', to: 'orders#checkout'
    get 'orders/success/:tracking_id', to:'orders#success', as: 'orders_success'
    get 'orders/cancel'
    # End of Sheet Purchase Routes

    devise_for :users, controllers: { registrations: 'users/registrations',
                                      omniauth_callbacks: 'users/omniauth_callbacks' }
    devise_scope :user do

      get '/', to: 'sheets#index', constraints: { subdomain: 'www' }
      get '/', to: 'users/registrations#profile', constraints: { subdomain: /.+/ }, as: :user_profile
      get '/favorites', to: 'sheets#index', constraints: { subdomain: 'www' }
      get '/favorites', to: 'users/registrations#favorites', constraints: { subdomain: /.+/ }, as: :user_favorites
      match 'users/finish_registration', to: 'users/registrations#finish_registration', via: [:get, :patch], as: :finish_registration
      get 'dashboard', to: 'users/registrations#dashboard', as: :user_dashboard
      get 'sales', to: 'users/registrations#sales', as: :user_sales
      get 'library', to: 'users/registrations#library', as: :user_library
      get 'trash', to: 'users/registrations#trash', as: :user_trash

      get '/settings', to: 'users/registrations#edit', as: :user_settings
      get '/settings/membership', to: 'users/registrations#edit_membership', as: :user_membership_settings
      get '/settings/password', to: 'users/registrations#edit_password', as: :user_password_settings
      patch '/settings/password', to: 'users/registrations#update_password', as: :user_password_update
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
    get 'assets/:id/download', to: 'assets#download', as: 'download_asset'

    root 'sheets#index'
    get 'browse', to: 'sheets#index', as: 'browse'
    get 'upload', to: 'sheets#new', as: 'sheet_upload'
    get 'search', to: 'sheets#search'
    get 'best-sellers', to: 'sheets#best_sellers'
    get 'community-favorites', to: 'sheets#community_favorites'

    get 'instruments', to: 'sheets#instruments'
    get 'instrument/:slug', to: 'sheets#by_instrument', as: 'instrument'

    get 'genres', to: 'sheets#genres'
    get 'genre/:slug', to: 'sheets#by_genre', as: 'genre'

    get 'composers', to: 'sheets#composers'
    get 'composer/:slug', to: 'sheets#by_composer', as: 'composer'

    get 'sources', to: 'sheets#sources'
    get 'source/:slug', to: 'sheets#by_source', as: 'source'

    get '/help', to: 'pages#faq', as: 'faq'
    get '/terms-of-service', to: 'pages#terms', as: 'terms'
    get '/privacy-policy', to: 'pages#privacy', as: 'privacy'
    get '/community-guidelines', to: 'pages#community_guidelines'
    get '/upgrade', to: 'pages#upgrade'
  end
end
