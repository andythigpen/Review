Review::Application.routes.draw do

  get "profile/edit" => "profile#edit", :as => :profile
  post "profile/update" => "profile#update"

  devise_for :users, :path_names => { :sign_in => "login", 
                                      :sign_up => "register", 
                                      :sign_out => "logout" }

  root :to => "home#index"
  match "changelog" => "home#changelog"

#resources :diffs
  resources :review_events

  match "reviewer/:review_event_id/:user_id" => "review_event_user#destroy",
        :as => :destroy_reviewer, :via => :delete
  match "reviewer/:review_event_id/:user_id" => "review_event_user#show", 
        :as => :reviewer, :via => :get

  get "reviewers/show"

  match "comments/create" => "comments#create", 
        :as => :create_comment, :via => :post
  match "comments/destroy" => "comments#destroy", 
        :as => :destroy_comment, :via => :post
  match "comments/:id" => "comments#show", :as => :comment

  get "changeset/:id" => "changeset#show", :as => :changeset
  post "changeset/create"
  post "changeset/update/:id" => "changeset#update"
  post "changeset/destroy/:id" => "changeset#destroy"

  post "diffs/create"
  post "diffs/destroy/:id" => "diffs#destroy"

  post "changeset/status" => "changeset_user_status#update"
  match "changeset/status/:id" => "changeset_user_status#destroy", 
        :via => :delete
  get "changeset/download/:id" => "changeset#download", 
      :as => :changeset_download

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
