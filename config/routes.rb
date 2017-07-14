Rails.application.routes.draw do
  default_url_options :host => Rails.application.secrets[:default_url_options]
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users
  root to: "deploy#index"
  get "/deploy" => "deploy#index"
  get "/deploy/:deployment_id" => "deploy#show"

  resources :environments, only: [:show] do
    resources :config_files do
      resources :versions, only: [:index, :show]
    end
    resources :logs
    get "/dispose" => "environments#dispose", as: :dispose
  end

  namespace :api do
    resources :deployments, only: [:index, :create] do
      post "redeployment", action: :redeployment
    end

    resources :deploy_environments, only: :show do
      get "deployments", action: :load_more_deployments
    end

    resources :logs, only: [:show]
    resources :deploy_environments, only: :show do
      post :scale
    end
  end

  ActiveAdmin.routes(self)
end
