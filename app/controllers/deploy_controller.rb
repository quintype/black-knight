class DeployController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    @deployment = current_user.deployments.find(params[:deployment_id])
    @current_deploy_environment = @deployment.deploy_environment
  end

  def environment
    @current_deploy_environment = current_user.deploy_environments.find(params[:deploy_environment_id])
    render :index
  end
end
