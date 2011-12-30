Uplo::Application.routes.draw do
  root :to => "home#index"

  # WEB ROUTING
  get 'images/list', :to => 'images#list'
  get 'images/delete/:id', :to => 'images#destroy'
  resources :galleries
  resources :images do 
    collection do 
      get 'slideshow'
    end 
  end

  devise_for :users, :controllers => {:registrations => "users/registrations", :sessions => "users/sessions",
    :confirmations => "users/confirmations", :passwords => "users/passwords" }

  devise_scope :user do
    get "signin", :to => "users/sessions#new"
    post "signin", :to => "users/sessions#new"
    get "register", :to => "users/registrations#new"
    delete "signout", :to => "users/sessions#destroy"
  end
  get "profile", :to => "users#profile"
  
  # API ROUTING
  namespace :api do
    devise_scope :user do
      post "login", :to => "users#login"
      get "logout", :to => "users#logout"
      get "user_info", :to => "users#get_user_info"
    end
    post "register", :to => "users#create_user"
    post "login", :to => "users#login"
    get "reset_password", :to => "users#reset_password"
    post "create_gallery", :to => "galleries#create_gallery"
    post "update_gallery", :to => "galleries#update_gallery"
    delete "delete_gallery", :to => "galleries#delete_gallery"
    get "list_galleries", :to => "galleries#list_galleries"
    post "upload_image", :to => "images#upload_image"
    post "update_image", :to => "images#update_image"
    delete "delete_image", :to => "images#delete_image"
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
