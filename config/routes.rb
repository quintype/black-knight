Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users

  get "/deploy" => "deploy#index"

  ActiveAdmin.routes(self)
end
