class DeployController < ApplicationController
  before_action :authenticate_user!,:unconfirmed_mfa?

  def index
    @current_deploy_environment = "none"
  end

  def show
    @deployment = current_deployment(params[:deployment_id])
    @current_deploy_environment = @deployment.deploy_environment
  end
end
