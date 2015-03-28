Rails.application.routes.draw do
  defaults subdomain: '' do
    resources :notes

    get 'upgrade/purchase/:membership', to: 'subscriptions#purchase', as: 'subscriptions_purchase'
    get 'upgrade/checkout/:membership', to: 'subscriptions#checkout', as: 'subscriptions_checkout'
    get 'upgrade/cancel', to: 'subscriptions#cancel', as: 'subscriptions_cancel'
    get 'upgrade/success', to: 'subscriptions#success', as: 'subscriptions_success'
    get 'downgrade/:membership', to: 'subscriptions#downgrade', as: 'subscriptions_downgrade'

    post 'orders/checkout', to: 'orders#checkout'
    post 'orders/get', to: 'orders#get'
    get 'orders/status/:tracking_id', to: 'orders#status', as: 'orders_status'
    get 'orders/cancel'

    devise_for :users, controllers: { registrations: 'users/registrations',
                                      omniauth_callbacks: 'users/omniauth_callbacks',
                                      sessions: 'users/sessions' }
    devise_scope :user do
      get '/discourse/sso', to: 'users/sessions#sso', as: :user_discourse_sso

      # Root Subdomain handling
      get '/', to: 'pages#homepage', constraints: { subdomain: '' }
      get '/likes', to: 'pages#homepage', constraints: { subdomain: '' }
      # end Root Subdomain handling

      get '/', to: 'users/registrations#profile', constraints: { subdomain: /.+/ }, as: :user_profile
      get '/users', to: 'users/registrations#all', constraints: { subdomain: '' }, as: :all_users
      get '/likes', to: 'users/registrations#likes', constraints: { subdomain: /.+/ }, as: :user_likes
      match 'users/finish_registration', to: 'users/registrations#finish_registration', via: [:get, :patch], as: :finish_registration
      get 'dashboard', to: 'users/registrations#dashboard', as: :user_dashboard
      get 'sales', to: 'users/registrations#sales', as: :user_sales
      get 'sales/download', to: 'users/registrations#csv_sales_data', as: :user_csv_sales_data
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
        get 'titles'
      end

      member do
        get 'fans'
        get 'download'
        post 'like'
        get 'report'
        post 'flag'
        post 'restore'
      end
    end

    resources :assets, only: [:create, :destroy]
    get 'assets/:id/download', to: 'assets#download', as: 'download_asset'

    root 'pages#homepage'
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

    get '/features', to: 'pages#features', as: 'features'
    get '/support', to: 'pages#support', as: 'support'
    get '/terms-of-service', to: 'pages#terms', as: 'terms'
    get '/privacy-policy', to: 'pages#privacy', as: 'privacy'
    get '/community-guidelines', to: 'pages#community_guidelines'
    get '/upgrade', to: 'pages#upgrade'

    get '/contact', to: 'contact_form#new', as: 'contact'
    post '/contact', to: 'contact_form#create', as: 'contact_forms'
  end
end
