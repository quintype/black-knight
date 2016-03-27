Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users

  get "/deploy" => "deploy#index"

  namespace :api do
    resources :publishers, only: :index
  end

  ActiveAdmin.routes(self)
end
