class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  acts_as_token_authentication_handler_for User
  before_action :configure_permitted_parameters, if: :devise_controller?

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
