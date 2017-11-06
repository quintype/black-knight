Rails.application.routes.draw do
  default_url_options :host => Rails.application.secrets[:default_url_options]
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  authenticated :admin_user do
    mount DelayedJobWeb, at: "/delayed_job"
  end

  devise_scope :user do
    scope :users, as: :users do
      post 'pre_otp', to: 'users/sessions#pre_otp'
    end
  end

  root to: "deploy#index"
  get "/deploy" => "deploy#index"
  get "/deploy/:deployment_id" => "deploy#show"


  namespace :users do
    get    '/two_factor' => 'two_factors#show', as: 'user_two_factor'
    post   '/two_factor' => 'two_factors#create'
    #delete '/two_factor' => 'two_factors#destroy'
  end

  resources :environments, only: [:show], param: :environment_id
  scope '/environments/:environment_id', as: :environment do
    resources :config_files do
      resources :versions, only: [:index, :show]
    end
    resources :logs, only: :index
    get "/dispose" => "environments#dispose", as: :dispose
    get "/migrations" => "environments#migrations"
    get '/migration/:migration_id' => "environments#migration_show"
  end

  namespace :api do
    resources :deployments, only: [:show, :create] do
      post "redeployment", action: :redeployment
    end

    resources :migrations, only: [:create, :destroy, :show]

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
