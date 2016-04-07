class DeployController < ApplicationController
  before_action :authenticate_user!

  def index
    @current_deploy_environment = "none"
  end

  def show
    @deployment = current_user.deployments.find(params[:deployment_id])
    @current_deploy_environment = @deployment.deploy_environment
  end

  def environment
    @current_deploy_environment = current_user.deploy_environments.find(params[:deploy_environment_id])
  end
end
