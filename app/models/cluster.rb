class Cluster < ApplicationRecord
  has_many :deploy_environments
end
