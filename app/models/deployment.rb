class Deployment < ApplicationRecord
  belongs_to :deploy_environment
  has_one :publisher, through: :deploy_environment
end
