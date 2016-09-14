class Api::DeploymentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  skip_before_filter :verify_authenticity_token

  def create
    deploy_params = params[:deployment]
    environment = current_user.deploy_environments.find(deploy_params[:deploy_environment_id])
    environment.update(last_tag: deploy_params[:version])
    deployment = environment.new_deployment(deploy_params[:version], current_user)
    if(deployment.save)
      respond_with({deployment: deployment}, location: "/deploy/#{deployment.id}")
      DeployContainerJob.perform_later(deployment.id, request.base_url)
    else
      respond_with deployment
    end
  end

  def show
    respond_with deployment: current_user.deployments.find(params[:id])
  end

  def redeployment
    old_deployment = current_user.deployments.find(params[:deployment_id])
    deployment = old_deployment.redeployment(current_user)
    if(deployment.save)
      respond_with({deployment: deployment}, location: "/deploy/#{deployment.id}")
      DeployContainerJob.perform_later(deployment.id, request.base_url)
    else
      respond_with deployment
    end
  end
end
