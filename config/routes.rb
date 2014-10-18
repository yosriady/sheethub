Rails.application.routes.draw do

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
      get 'purchase'
      get 'download_pdf'
      get 'like'
      post 'flag'
    end
  end

  resources :assets, only: [:create, :destroy]

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

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
