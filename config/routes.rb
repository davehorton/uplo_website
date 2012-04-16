Uplo::Application.routes.draw do
  get "orders/index"

  # WEB ROUTING
  root :to => "home#index"
  get '/test', :to => "images#get_flickr_authorize"
  match '/flickr_response' => 'images#flickr_response'
  get "shopping_cart/show"
  post "shopping_cart/update_cart"
  post "shopping_cart/add_to_cart"
  get "shopping_cart/destroy_item"
  get "shopping_cart/clear"
  get "shopping_cart/checkout"
  get "orders", :to => "orders#index"
  get "browse", :to => "home#browse"
  get "search", :to => "home#search"
  get "spotlight", :to => "home#spotlight"
  get "intro", :to => "home#intro"
  get "popular", :to => "home#popular"
  get "back", :to => "application#redirect_back"
  get "profile", :to => "users#profile"
  get "profile/edit", :to => "users#edit"
  put "profile/update", :to => "users#update"

  match 'images/browse/:id' => 'images#browse', :via => [:get]
  match 'images/public/:id' => 'images#browse_share', :via => [:get]
  get 'images/order/:id', :to => "images#order"
  get 'images/switch_like/:id', :to => 'images#switch_liked'

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

  get 'galleries/search', :to => 'galleries#search'
  get 'galleries/search_public', :to => 'galleries#search_public'
  get 'galleries/show_public', :to => 'galleries#show_public'
  get 'users/search', :to => 'users#search'
  resources :galleries do
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
    end

    # Gallery
    post "create_gallery", :to => "galleries#create_gallery"
    post "update_gallery", :to => "galleries#update_gallery"
    post "delete_gallery", :to => "galleries#delete_gallery"
    get "list_galleries", :to => "galleries#list_galleries"
    get "list_images", :to => "galleries#list_images"
    get "list_popular", :to => "galleries#list_popular"
    get "popular_images", :to => "images#popular_images"
    get "search", :to => "search#search"

    # Image
    post "upload_image", :to => "images#upload_image"
    post "update_image", :to => "images#update_image"
    post "delete_image", :to => "images#delete_image"
    get "image_total_sales", :to => "images#total_sales"
    get "sale_chart", :to => "images#sale_chart"
    get "image_purchasers", :to => "images#get_purchasers"
    get "get_images", :to => "images#get_images"

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
