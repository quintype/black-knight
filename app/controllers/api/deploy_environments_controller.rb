class Api::DeployEnvironmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def attributes_for_environment_page(deploy_environment, page= nil)
    if page
      deploy_environment.deployments.all.reverse_order.page(page).per(5)
    else
      deploy_environment.attributes.merge(deployments: deploy_environment.deployments.latest.map { |deployment|
        deployment.attributes.slice("id", "version", "deploy_tag", "status")
      })
    end
  end

  def show
    respond_with deploy_environment: attributes_for_environment_page(current_user.deploy_environments.find(params[:id]))
  end

  def load_more_deployments()
    vars = request.query_parameters
    respond_with more_deployments: attributes_for_environment_page(current_user.deploy_environments.find(params[:deploy_environment_id]), vars['page'])
  end
end
