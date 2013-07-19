require 'sidekiq/web'

Uplo::Application.routes.draw do

  # WEB ROUTING
  root :to => "home#index"

  # preserve legacy path
  match '/intro' => redirect('/iphone_app')

  get "shopping_cart/show"
  post "shopping_cart/update_cart"
  post "shopping_cart/add_to_cart"
  get "shopping_cart/destroy_item"
  get "shopping_cart/clear"
  get "shopping_cart/checkout"

  get "browse", :to => "home#browse"
  get "require_login", :to => "home#require_login"
  get "search", :to => "home#search"
  get "spotlight", :to => "home#spotlight"
  get "terms", :to => "home#terms"
  get "payment", :to => "home#payment"
  get "iphone_app", :to => "home#iphone_app"
  get 'friends', :to => 'home#friends_feed'
  get "back", :to => "application#redirect_back"
  get "my_account", :to => "users#account"
  get "my_account/edit", :to => "users#edit"
  put "my_account/update", :to => "users#update"

  resources :invitations, only: [:create] do
    member do
      get :accept_gallery_invitation
    end
  end

  resources :orders, only: [:index, :show]

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
    resources :gallery_invitations
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
      get  :print_image_preview
      get  :liking_users
      get  :product_options
      get  :public
      put  :switch_like
      get  :switch_like
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

  match '/auth/:provider/callback' => 'authentications#create'
  resources :authentications

  devise_for :users, :controllers => {:registrations => "registrations", :sessions => "users/sessions",
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
    resources :sizes, except: [:show]
    resources :mouldings, except: [:show]

    resources :image_tools, only: [:index] do
      collection do
        get :low_res_tool
      end
    end

    resources :shipping_prices
    resources :orders do
      member do
        post :resend_fulfillment_email
        post :regenerate_print
      end
    end
    resources :hidden_images, :only => [:index] do
      member do
        put :toggle_hidden_by_admin
      end
    end
  end

  # API ROUTING
  namespace :api do
    # User
    devise_scope :user do

      resources :galleries, except: [:show, :edit]

      resources :images do
        collection do
          get :by_friends
          get :liked
          get :popular
          get :search
          get :search_by_id
        end

        member do
          post :flag
          post :like
          get  :print_image_preview
          get  :purchases
          get  :sale_chart
          get  :total_sales
          post :unlike
        end

        resources :comments, only: [:index, :create]
      end

      resource :orders, only: [:create] do
        collection do
          post :add_item
          put  :update_item
          get  :cart
        end
      end

      resources :users, only: [:show] do
        collection do
          post :check_emails
          get :search
        end

        member do
          get :followers
          get :following
        end
      end

      post "register", :to => "users#register"
      get "total_sales", :to => "users#get_total_sales"
      post "login", :to => "users#login"
      post "logout", :to => "users#logout"
      get "reset_password", :to => "users#reset_password"
      post "update_profile", :to => "users#update_profile"
      get 'follow', :to => 'users#set_follow'
      get 'get_notification_settings', :to => 'users#get_notification_settings'
      post 'update_notification_settings', :to => 'users#update_notification_settings'
      get 'payment_info', :to => "users#get_user_payment_info"
      post 'withdraw', :to => "users#withdraw"
      get 'card_info', :to => "users#get_user_card_info"
      post 'request_invitation', :to => 'users#request_invitation'
      post 'delete_ordered_item', :to => 'orders#delete_ordered_item'
    end
  end

  # allow sidekiq dashboard access to admins only
  constraint = lambda { |request| Rails.env.development? || (request.env["warden"].authenticate? and request.env['warden'].user.admin?) }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end
end
