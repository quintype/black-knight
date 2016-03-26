class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_publishers
  has_many :publishers, through: :user_publishers

  def display_name
    "#{name} (#{email})"
  end
end
