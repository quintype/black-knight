class Deployment < ApplicationRecord
  belongs_to :deploy_environment
  has_one :publisher, through: :deploy_environment

  scope :latest, -> { order("id desc").limit(5) }
end
