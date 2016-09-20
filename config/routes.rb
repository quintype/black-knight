Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users

  root to: "deploy#index"
  get "/deploy" => "deploy#index"
  get "/deploy/:deployment_id" => "deploy#show"

  resources :environments, only: [:show] do
    resources :config_files
  end
  
  namespace :api do
    resources :deployments, only: [:show, :create] do
      post "redeployment", action: :redeployment
    end
    resources :deploy_environments, only: :show do
      get "deployments", action: :load_more_deployments
    end
  end

  mount ActionCable.server => '/cable'

  ActiveAdmin.routes(self)
end
