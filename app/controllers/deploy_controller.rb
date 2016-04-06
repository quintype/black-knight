class DeployController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    @deployment = current_user.deployments.find(params[:deployment_id])
    @current_deploy_environment = @deployment.deploy_environment
  end
end
