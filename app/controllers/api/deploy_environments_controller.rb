class Api::DeployEnvironmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  skip_before_filter :verify_authenticity_token, only: [:scale]

  def attributes_for_environment_page(deploy_environment)
    deploy_environment.attributes.merge(deployments: deploy_environment.deployments.latest.map { |deployment|
      deployment.attributes.slice("id", "version", "deploy_tag", "status")
    })
  end

  def show
    respond_with deploy_environment: attributes_for_environment_page(current_user.deploy_environments.find(params[:id]))
  end

  def scale
    deploy_environment = current_user.deploy_environments.find(params[:deploy_environment_id])
    size = params[:size]
    if(deploy_environment.disposable? && size < 4)
      ScaleContainerJob.perform_later(deploy_environment.id, current_user.id, size)
      render status: 201, json: {"state": "accepted"}
    else
      render status: 422
    end
  end
end
