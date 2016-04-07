Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users

  root to: "deploy#index"
  get "/environment/:deploy_environment_id" => "deploy#environment"
  get "/deploy" => "deploy#index"
  get "/deploy/:deployment_id" => "deploy#show"

  namespace :api do
    resources :publishers, only: :index
    resources :deployments, only: [:show, :create]
  end

  mount ActionCable.server => '/cable'

  ActiveAdmin.routes(self)
end
