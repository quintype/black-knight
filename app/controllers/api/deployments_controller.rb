class Api::DeploymentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  skip_before_filter :verify_authenticity_token

  def create
    deploy_params = params[:deployment]
    environment = current_user.deploy_environments.find(deploy_params[:deploy_environment_id])
    deployment = environment.new_deployment(deploy_params[:version])
    if(deployment.save)
      respond_with({deployment: deployment}, location: "/deploy/#{deployment.id}")
    else
      respond_with deployment
    end
  end

  def show
    respond_with deployment: current_user.deployments.find(params[:id])
  end
end
