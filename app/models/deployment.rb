class Deployment < ApplicationRecord
  belongs_to :deploy_environment
  belongs_to :scheduled_by, class_name: "User"
  belongs_to :cancelled_by, class_name: "User"

  has_one :publisher, through: :deploy_environment

  scope :latest, -> { order("id desc").limit(5) }

  def attributes
    super.merge(scheduled_by: scheduled_by, cancelled_by: cancelled_by)
  end
end
