Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users

  root to: "deploy#index"
  get "/environment/:deploy_environment_id" => "deploy#environment"
  get "/deploy" => "deploy#index"
  get "/deploy/:deployment_id" => "deploy#show"
  get "environment/:deploy_environment_id/config_files" => "config_files#index", as: :config_files_list
  # get "/configfiles/:config_file_id" => "config_files#show", as: :config_file
  # get "/configfiles/new" => "config_files#new", as: :new_config_file
  # get "/configfiles/:config_file_id/edit" => "config_files#update", as: :edit_config_file
  # post "/configfiles" => "config_files#create", as: :create_config_file
  # put "configfiles/:config_file_id" => "config_files#update", as: :update_config_file
  # delete "configfiles/:config_file_id" => "config_files#destroy", as: 
  resources :config_files, except: :index

  namespace :api do
    resources :deployments, only: [:show, :create] do
      post "redeployment", action: :redeployment
    end
    resources :deploy_environments, only: :show
  end

  mount ActionCable.server => '/cable'

  ActiveAdmin.routes(self)
end
