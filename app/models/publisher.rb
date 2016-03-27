class Publisher < ApplicationRecord
  include ActiveModel::Serialization

  has_many :deploy_environments

  def attributes
    super.merge(deploy_environments: deploy_environments)
  end
end
