class User::TwoFactorsController < ApplicationController
  before_filter :authenticate_user!

  def new
  end

  # If user has already enabled the two-factor auth, we generate a
  #   temp. otp_secret and show the 'new' template.
  # Otherwise we show the 'show' template which will allow the user to disable
  #   the two-factor auth
  def show
    unless current_user.otp_required_for_login?
      current_user.unconfirmed_otp_secret = User.generate_otp_secret
      current_user.save!
      @qr = RQRCode::QRCode.new(two_factor_otp_url).to_img.resize(240, 240).to_data_url
      render 'new'
    end
  end

  # User#activate_two_factor will return a boolean. When false is returned
  #   we presume the model has some errors.
  def create
    permitted_params = params.require(:user).permit :password, :otp_attempt
    if current_user.activate_two_factor permitted_params
      redirect_to root_path, notice: "You have enabled Two Factor Auth"
    else
      render 'new'
    end
  end

  # If the provided password is correct, two-factor is disabled
  def destroy
    permitted_params = params.require(:user).permit :password
    if current_user.deactivate_two_factor permitted_params
      redirect_to root_path, notice: "You have disabled Two Factor Auth"
    else
      render 'show'
    end
  end

  private

  # The url needed to generate the QRCode so it can be acquired by
  #   Google Authenticator
  def two_factor_otp_url
    "otpauth://totp/%{app}?secret=%{secret}&issuer=%{app_id}" % {
      :secret => current_user.unconfirmed_otp_secret,
      :app    => "black-knight",
      :app_id => "#{current_user.email}"
    }
  end
end

