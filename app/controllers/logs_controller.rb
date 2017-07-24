class LogsController < ApplicationController 
  before_action :authenticate_user!,:unconfirmed_mfa?

  before_action :load_current_environment

  def load_current_environment
    @current_deploy_environment = current_deploy_environment(params[:environment_id])
    @username = @current_deploy_environment.publisher.username
    @app_name = @current_deploy_environment.app_name
  end

  def index
    @pod_list = @current_deploy_environment.running_pods(@app_name, @username)
    @log_files =  @current_deploy_environment.log_files
  end
end
