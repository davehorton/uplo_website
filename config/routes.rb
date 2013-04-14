require 'sidekiq/web'

Uplo::Application.routes.draw do

  # WEB ROUTING
  root :to => "home#index"

  resources :invitations, only: [:create]

  get "shopping_cart/show"
  post "shopping_cart/update_cart"
  post "shopping_cart/add_to_cart"
  get "shopping_cart/destroy_item"
  get "shopping_cart/clear"
  get "shopping_cart/checkout"

  get "orders/index"
  get "orders", :to => "orders#index"
  get "browse", :to => "home#browse"
  get "search", :to => "home#search"
  get "spotlight", :to => "home#spotlight"
  get "terms", :to => "home#terms"
  get "payment", :to => "home#payment"
  get "intro", :to => "home#intro"
  get 'friends', :to => 'home#friends_feed'
  get "back", :to => "application#redirect_back"
  get "my_account", :to => "users#account"
  get "my_account/edit", :to => "users#edit"
  put "my_account/update", :to => "users#update"

  resource :profile, only: [:show] do
    member do
      get :photos
      get :get_photos
      get :likes
      get :get_likes
      get :galleries
      get :get_galleries
      get :followers
      get :get_followers
      get :followed_users
      get :get_followed_users
      get :followed_users
      get :get_followed_users
    end
  end

  get 'profile/:user_id', :to => 'profiles#show', :as => :profile_user

  get 'galleries/edit_images', :to => 'galleries#edit_images'

  resources :galleries do
    member do
      get :edit_images
      get :public
      get :share
    end

    collection do
      get :search
      get :search_public
      get :show_public
    end

    get 'public_images', :to => 'images#public_images'
    get 'images/search', :to => 'images#search'
    get 'images/load_image', :to => 'images#get_image_data'
    put 'filter_status', :to => 'images#get_filter_status'

    resources :images
  end

  resources :images, only: [] do
    collection do
      put :update_images
    end

    member do
      get  :browse
      post :flag
      get  :flickr_authorize
      get  :flickr_post
      get  :flickr_response
      post  :mail_shared_image
      get  :order
      get  :price
      get  :pricing
      get  :public
      put  :switch_like
      put  :tier
    end
  end

  get "invites/index"

  get "sales", :to => "sales#index"
  get "sales/year_sales", :to => "sales#year_sales"
  get "sales/image_sale_details", :to => "sales#image_sale_details"
  post "sales/withdraw", :to => "sales#withdraw"

  match '/payments/paypal_notify' => 'payments#paypal_notify'
  match '/payments/paypal_result' => 'payments#paypal_result'
  match '/payments/paypal_cancel' => 'payments#paypal_cancel'
  match '/payments/checkout' => 'payments#checkout'
  get '/payments/checkout_result' => 'payments#checkout_result'
  post '/payments/auth_order' => 'payments#auth_order'

  resources :payments
  resources :comments


  get 'users/search', :to => 'users#search'
  get 'users/follow', :to => 'users#set_follow'

  devise_for :users, :controllers => {:registrations => "users/registrations", :sessions => "users/sessions",
    :confirmations => "users/confirmations", :passwords => "users/passwords" }

  devise_scope :user do
    put "users/enable_social", :to => "users#enable_social"
    put "users/disable_social", :to => "users#disable_social"

    resources :users do
    end

    get "signin", :to => "users/sessions#new"
    post "signin", :to => "users/sessions#new"
    get "register", :to => "users/registrations#new"
    delete "signout", :to => "users/sessions#destroy"
    get "change_password", :to => "users/passwords#edit_password"
    put "update_password", :to => "users/passwords#update_password"
    post 'update_avatar', :to => 'users#update_avatar'
    get 'delete_profile_photo', :to => 'users#delete_profile_photo'
    get 'set_avatar', :to => 'users#set_avatar'
    put 'update_profile_info', :to => 'users#update_profile_info'
    get 'unlike_image', :to => 'users#unlike_image'
  end

  # SOCIAL NETWORK
  get "socials/facebook_callback", :to => "socials#facebook_callback"
  get "socials/twitter_callback", :to => "socials#twitter_callback"
  get "socials/tumblr_callback", :to => "socials#tumblr_callback"
  get "socails/flickr_callback", :to => "socials#flickr_callback"

  post "socials/share", :to => "socials#share"

  # ADMIN SECTIONS
  get '/admin', :to => "admin/admin#index"
  namespace :admin do
    resources :flagged_images do
      collection do
        get :index
        get :get_image_popup
        post :reinstate_all
        post :remove_all
        post :reinstate_image
        post :remove_image
      end
    end

    resources :flagged_users do
      collection do
        post :reinstate_all
        post :remove_all
      end

      member do
        post :reinstate_user
        post :remove_user
      end
    end

    resources :members do
      collection do
        get :search
      end
    end

    resources :spotlights do
      collection do
        get :search
      end

      member do
        post :promote
      end
    end

    resources :invites do
      collection do
        post :send_invitation
        get :confirm_request
      end
    end

    resources :products, except: [:show]
    resources :sizes, except: [:show] do
      get :rebuild_photos, on: :collection
    end
    resources :mouldings, except: [:show]

    resources :image_tools, only: [:index] do
      collection do
        get :low_res_tool
      end
    end
  end

  # API ROUTING
  namespace :api do
    resources :galleries, except: [:show, :edit] do
      get :popular, on: :collection
    end

    resources :images do
      collection do
        get :by_friends
        get :liked
        get :mouldings
        get :popular
        get :search
        get :user_images
      end

      member do
        post :like
        get  :ordering_options
        get  :purchases
        get  :sale_chart
        get  :total_sales
        put  :unlike
      end

      resources :comments, only: [:index, :create]
    end

    get "search", :to => "search#search"

    # Order
    get "list_orders", :to => "orders#list_orders"
    post "create_order", :to => "orders#create_order"
    post "finalize_order", :to => "orders#finalize_order"
    post 'update_ordered_item', :to => 'orders#update_ordered_item'
    post 'add_ordered_item', :to => 'orders#add_ordered_item'
    post 'delete_ordered_item', :to => 'orders#delete_ordered_item'
    get 'show_cart', :to => 'orders#show_cart'

    # User
    devise_scope :user do
      get "total_sales", :to => "users#get_total_sales"
      post "login", :to => "users#login"
      post "logout", :to => "users#logout"
      get "user_info", :to => "users#get_user_info"
      post "register", :to => "users#create_user"
      get "reset_password", :to => "users#reset_password"
      post "update_profile", :to => "users#update_profile"
      get 'user_followings', :to => 'users#get_followed_users'
      get 'user_followers', :to => 'users#get_followers'
      get 'follow', :to => 'users#set_follow'
      get 'check_following', :to => 'users#check_following'
      get 'get_notification_settings', :to => 'users#get_notification_settings'
      post 'update_notification_settings', :to => 'users#update_notification_settings'
      get "check_emails", :to => "users#check_emails"
      get 'payment_info', :to => "users#get_user_payment_info"
      post 'withdraw', :to => "users#withdraw"
      get 'card_info', :to => "users#get_user_card_info"
      post 'request_invitation', :to => 'users#request_invitation'
    end
  end

  # allow sidekiq dashboard access to admins only
  constraint = lambda { |request| Rails.env.development? || (request.env["warden"].authenticate? and request.env['warden'].user.admin?) }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end
end
