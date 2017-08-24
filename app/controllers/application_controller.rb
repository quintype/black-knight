class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  acts_as_token_authentication_handler_for User
  before_action :configure_permitted_parameters, if: :devise_controller?

    # FIXME MOVE TO USER
    def current_deploy_environment(id)
      if current_user.super_user?
        @current_deploy_environment = DeployEnvironment.find(id)
      else
        @current_deploy_environment = current_user.deploy_environments.find(id)
      end
    end

    def current_deployment(id)
      if current_user.super_user?
        Deployment.find(id)
      else
        current_user.deployments.find(id)
      end
    end

    def current_migration(id)
      if current_user.super_user?
        Migration.find(id)
      else
        current_user.migrations.find(id)
      end
    end

  protected
  	def configure_permitted_parameters
  		devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :name, :password, :password_confirmation])
        devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
  	end

    def unconfirmed_mfa!
        return true unless current_user && current_user.unconfirmed_mfa?
        redirect_to :users_user_two_factor
    end
end
