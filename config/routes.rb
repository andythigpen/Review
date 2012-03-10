Review::Application.routes.draw do

  # User authentication
  devise_for :users, :path_names => { :sign_in => "login", 
                                      :sign_up => "register", 
                                      :sign_out => "logout" }
  put "/users/settings" => "user_settings#update", :as => :user_settings

  # Dashboard
  root :to => "home#dashboard"
  match "/dashboard/inbox"  => "home#inbox"
  match "/dashboard/all_inbox"  => "home#all_inbox"
  match "/dashboard/due_soon"  => "home#due_soon"
  match "/dashboard/late"  => "home#late"
  match "/dashboard/outbox" => "home#outbox"
  match "/dashboard/all_outbox"  => "home#all_outbox"
  match "/dashboard/drafts" => "home#drafts"
  match "/dashboard/accepted" => "home#accepted"
  match "/dashboard/rejected" => "home#rejected"

  # Review events
  resources :review_events, :except => :index
  match "/reviewer/:user_id" => "reviewers#reviewer"
  match "/reviewer/group/:group_id" => "reviewers#group"

  # Groups
  resources :groups

  # Comments
  #TODO resources :comments

  match "comments/create" => "comments#create", 
        :as => :create_comment, :via => :post
  match "comments/destroy" => "comments#destroy", 
        :as => :destroy_comment, :via => :post
  match "comments/:id" => "comments#show", :as => :comment

  # Changesets
  get "changeset/:id" => "changeset#show", :as => :changeset
  post "changeset/create"
  post "changeset/update/:id" => "changeset#update"
  post "changeset/destroy/:id" => "changeset#destroy"

  # Diffs
  post "diffs/create"
  post "diffs/destroy/:id" => "diffs#destroy"

  # Changeset Statuses
  # post "changeset/:changeset_id/user/:user_id/status" => "changeset_user_status#update"
  post "changeset/status" => "changeset_user_status#update"
  match "changeset/status/:id" => "changeset_user_status#destroy", 
        :via => :delete

  get "changeset/download/:id" => "changeset#download", 
      :as => :changeset_download

  # Profiles
  get "profile/edit" => "profile#edit", :as => :profile
  post "profile/update" => "profile#update"

  # reviewer autocomplete
  # get "reviewers/show"
  
  match "/delayed_job" => DelayedJobWeb, :anchor => false

  match ':action' => 'static#:action', :as => :static
end
