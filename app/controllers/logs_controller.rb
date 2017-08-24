class LogsController < ApplicationController
  before_action :authenticate_user!,:unconfirmed_mfa!

  def index
    @current_deploy_environment = current_user.deploy_environments.find(params[:environment_id])
    @pod_list = @current_deploy_environment.running_pods
    @log_files =  @current_deploy_environment.log_files
  end
end
