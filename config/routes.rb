Uplo::Application.routes.draw do

  # WEB ROUTING
  root :to => "home#index"
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
  get "intro", :to => "home#intro"
  get 'friends', :to => 'home#friends_feed'
  get "popular", :to => "home#popular"
  get "back", :to => "application#redirect_back"
  get "my_account", :to => "users#profile"
  get "my_account/edit", :to => "users#edit"
  put "my_account/update", :to => "users#update"
  get 'profile', :to => 'profiles#show'
  get 'profile/photos', :to => 'profiles#show_photos'
  get 'profile/get_photos', :to => 'profiles#get_photos'
  get 'profile/likes', :to => 'profiles#show_likes'
  get 'profile/get_likes', :to => 'profiles#get_likes'
  get 'profile/galleries', :to => 'profiles#show_galleries'
  get 'profile/get_galleries', :to => 'profiles#get_galleries'
  get 'profile/followers', :to => 'profiles#show_followers'
  get 'profile/get_followers', :to => 'profiles#get_followers'
  get 'profile/followed_users', :to => 'profiles#show_followed_users'
  get 'profile/get_followed_users', :to => 'profiles#get_followed_users'

  get 'images/browse/:id', :to => 'images#browse'
  get 'images/public/:id', :to => 'images#public'
  get 'images/order/:id', :to => "images#order"
  get 'images/switch_like', :to => 'images#switch_liked'
  get 'images/flickr_authorize', :to => "images#get_flickr_authorize"
  get 'images/flickr_response' => 'images#flickr_response'
  get 'images/flickr_post', :to => 'images#post_image_to_flickr'
  post 'images/mail_shared_image', :to => 'images#mail_shared_image'
  post 'images/update_images', :to => 'images#update_images'
  get "images/flag", :to => "images#flag"
  get 'images/show_pricing', :to => 'images#show_pricing'
  post 'images/update_tier', :to => 'images#update_tier'
  get 'images/get_price',:to => 'images#get_price'

  get "sales", :to => "sales#index"
  get "sales/year_sales", :to => "sales#year_sales"
  get "sales/image_sale_details", :to => "sales#image_sale_details"

  match '/payments/paypal_notify' => 'payments#paypal_notify'
  match '/payments/paypal_result' => 'payments#paypal_result'
  match '/payments/paypal_cancel' => 'payments#paypal_cancel'
  match '/payments/checkout' => 'payments#checkout'
  get '/payments/checkout_result' => 'payments#checkout_result'
  post '/payments/auth_order' => 'payments#auth_order'

  resources :payments
  resources :comments

  get 'galleries/search', :to => 'galleries#search'
  get 'galleries/search_public', :to => 'galleries#search_public'
  get 'galleries/show_public', :to => 'galleries#show_public'
  get 'users/search', :to => 'users#search'
  get 'users/follow', :to => 'users#set_follow'
  get 'galleries/edit_images', :to => 'galleries#edit_images'
  resources :galleries do
    post 'mail_shared_gallery', :to => 'galleries#mail_shared_gallery'
    get 'public', :to => 'galleries#public'
    get 'public_images', :to => 'images#public_images'
    get 'images/search', :to => 'images#search'
    get 'images/delete/:id', :to => 'images#destroy'
    get 'images/list', :to => 'images#list'
    get 'images/load_image', :to => 'images#get_image_data'
    put 'filter_status', :to => 'images#get_filter_status'
    resources :images
  end

  devise_for :users, :controllers => {:registrations => "users/registrations", :sessions => "users/sessions",
    :confirmations => "users/confirmations", :passwords => "users/passwords" }

  devise_scope :user do
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

  # ADMIN SECTIONS
  get '/admin', :to => "admin/admin#index"
  namespace :admin do
    resources :flagged_images do
      post :index, :on => :collection
      post :reinstate_all, :on => :collection
      post :remove_all, :on => :collection
      post :reinstate_image, :on => :collection
      delete :remove_image, :on => :collection
    end

    resources :flagged_users do
      post :index, :on => :collection
      post :reinstate_all, :on => :collection
      post :remove_all, :on => :collection
      post :reinstate_images, :on => :collection
      delete :remove_images, :on => :collection
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
  end

  # API ROUTING
  namespace :api do
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
      post 'get_notification_settings', :to => 'users#get_notification_settings'
      post 'update_notification_settings', :to => 'users#update_notification_settings'
    end

    # Gallery
    post "create_gallery", :to => "galleries#create_gallery"
    post "update_gallery", :to => "galleries#update_gallery"
    post "delete_gallery", :to => "galleries#delete_gallery"
    get "list_galleries", :to => "galleries#list_galleries"
    get "list_images", :to => "galleries#list_images"
    get "list_popular", :to => "galleries#list_popular"
    get "popular_images", :to => "images#popular_images"
    get 'friend_images', :to => 'images#friend_images'
    get "search", :to => "search#search"

    # Image
    post "upload_image", :to => "images#upload_image"
    post "update_image", :to => "images#update_image"
    post "delete_image", :to => "images#delete_image"
    get "image_total_sales", :to => "images#total_sales"
    get "sale_chart", :to => "images#sale_chart"
    get "image_purchasers", :to => "images#get_purchasers"
    get "get_images", :to => "images#get_images"
    get 'get_printed_sizes', :to => 'images#get_printed_sizes'
    get 'user_images', :to => 'images#get_user_images'
    get 'list_comments', :to => 'images#get_comments'
    post 'post_comment', :to => 'images#post_comment'
    post 'flag_image', :to => 'images#flag_image'

    # Order
    get "list_orders", :to => "orders#list_orders"
    post "create_order", :to => "orders#create_order"
    get "like", :to => "images#like"
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
