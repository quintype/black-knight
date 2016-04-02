Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users

  get "/deploy" => "deploy#index"
  get "/deploy/:deployment_id" => "deploy#show"

  namespace :api do
    resources :publishers, only: :index
    resources :deployments, only: [:show, :create]
  end

  ActiveAdmin.routes(self)
end
