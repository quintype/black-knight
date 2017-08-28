class User < ApplicationRecord
  acts_as_token_authenticatable
  devise :two_factor_authenticatable,:registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :otp_secret_encryption_key => "#{Rails.application.secrets[:TWO_FACTOR_SECRET_KEY]}"

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  has_many :user_publishers
  has_many :publishers, ->(user) { user.super_user? ? unscope(:where, :joins) : all }, through: :user_publishers
  has_many :deploy_environments, through: :publishers
  has_many :deployments, through: :deploy_environments
  has_many :migrations, through: :deploy_environments

  def display_name
    "#{name} (#{email})"
  end

  def activate_two_factor(params)
    if !valid_password?(params[:password])
      errors.add :password, :invalid
      false
    elsif !validate_and_consume_otp!(params[:otp_attempt], otp_secret: unconfirmed_otp_secret)
      errors.add :otp_attempt, :invalid
      false
    else
      activate_two_factor!
    end
  end

  def deactivate_two_factor(params)
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
    self.otp_secret = unconfirmed_otp_secret
    self.unconfirmed_otp_secret = nil
    self.unconfirmed_mfa = false
    save
  end
end
