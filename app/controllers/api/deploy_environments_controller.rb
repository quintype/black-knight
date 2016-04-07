class Api::DeployEnvironmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def attributes_for_environment_page(deploy_environment)
    deploy_environment.attributes.merge(deployments: deploy_environment.deployments.latest.map { |deployment|
      deployment.attributes.slice("id", "version", "deploy_tag", "status")
    })
  end

  def show
    respond_with deploy_environment: attributes_for_environment_page(current_user.deploy_environments.find(params[:id]))
  end
end
