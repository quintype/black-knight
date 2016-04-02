class DeployContainerJob < ApplicationJob
  queue_as :default

  def perform(deployment_id)
    deployment = Deployment.find(deployment_id)
    BuildContainer.build_and_deploy!(deployment)
  end
end
