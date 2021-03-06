class KubeStatusController < ApplicationController
  before_action :authenticate_user!,:unconfirmed_mfa!

  def index
    @current_deploy_environment = current_user.deploy_environments.find(params[:environment_id])
    @app_status = @current_deploy_environment.kube_status
  end
end
