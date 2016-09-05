class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_publishers
  has_many :publishers, through: :user_publishers
  has_many :deploy_environments, through: :publishers
  has_many :deployments, through: :deploy_environments
  has_many :config_files, through: :deploy_environments

  def display_name
    "#{name} (#{email})"
  end
end
