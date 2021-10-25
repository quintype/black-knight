class Deployment < ApplicationRecord
  acts_as_paranoid
  belongs_to :deploy_environment
  belongs_to :scheduled_by, class_name: "User"
  belongs_to :cancelled_by, class_name: "User"
  belongs_to :redeploy_of, class_name: "Deployment"

  has_one :publisher, through: :deploy_environment

  scope :latest, -> { order("id desc").limit(5) }

  def attributes
    super.merge(scheduled_by: scheduled_by, cancelled_by: cancelled_by, :buildable? => buildable?)
  end

  def redeployment(user)
    deploy_environment.new_redeployment(self, user)
  end

  def redeployment?
    redeploy_of_id.present?
  end

  def buildable?
    !redeployment?
  end

  def new_deploy_tag
    if redeployment?
      deploy_tag
    else
      "#{deploy_environment.publisher.username}-#{deploy_environment.name}-" + DateTime.now.strftime("%Y%m%d%H%M%S")
    end
  end

  def execute_command
    "docker-deploy.sh"
  end

  def execute_arguments
    []
  end
end
