class Api::DeployEnvironmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json
  skip_before_filter :verify_authenticity_token, only: [:scale]

  def attributes_for_environment_page(deploy_environment, page=nil)
    if page
      deploy_environment.deployments.all.reverse_order.page(page).per(5).map {|deployment|
        deployment.attributes.slice("id", "version", "deploy_tag", "status")
      }
    else
      deploy_environment.attributes.merge(deployments: deploy_environment.deployments.latest.map { |deployment|
        deployment.attributes.slice("id", "version", "deploy_tag", "status")
      })
    end
  end

  def show
    respond_with deploy_environment: attributes_for_environment_page(current_deploy_environment(params[:id]))
  end

  def scale
    deploy_environment = current_deploy_environment(params[:deploy_environment_id])
    size = params[:size]
    if(deploy_environment.disposable? && size < 4)
      ScaleContainerJob.perform_later(deploy_environment.id, current_user.id, size)
      render status: 201, json: {"state": "accepted"}
    else
      render status: 422, json: {error: {message: "Cannot Scale This Container"}}
    end
  end

  def load_more_deployments()
    vars = request.query_parameters
    respond_with more_deployments: attributes_for_environment_page(current_deploy_environment(params[:deploy_environment_id]), vars['page'])
  end
end
