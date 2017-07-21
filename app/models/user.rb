class User < ApplicationRecord
  devise :two_factor_authenticatable,
         :otp_secret_encryption_key => Rails.application.secrets.TWO_FACTOR_SECRET_KEY

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_publishers
  has_many :publishers, through: :user_publishers
  has_many :deploy_environments, through: :publishers
  has_many :deployments, through: :deploy_environments
  
  def display_name
    "#{name} (#{email})"
  end

  def activate_two_factor params
    otp_params = { otp_secret: unconfirmed_otp_secret }
    if !valid_password?(params[:password])
      errors.add :password, :invalid
      false
    elsif !valid_otp?(params[:otp_attempt], otp_params)
      errors.add :otp_attempt, :invalid
      false
    else
      activate_two_factor!
    end
  end

  def deactivate_two_factor params
    if !valid_password?(params[:password])
      errors.add :password, :invalid
      false
    else
      self.otp_required_for_login = false
      self.otp_secret = nil
      save
    end
  end

  private
  
  def activate_two_factor!
    self.otp_required_for_login = true
    p unconfirmed_otp_secret
    self.otp_secret = unconfirmed_otp_secret
    self.unconfirmed_otp_secret = nil
    save
  end
end
