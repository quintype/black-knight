class Api::LogsController < ApplicationController
  before_action :authenticate_user!,:unconfirmed_mfa!
  respond_to :json

  skip_before_filter :verify_authenticity_token, only: [:scale]

  before_action :load_current_environment

  def load_current_environment
    @current_deploy_environment = current_deploy_environment(params[:id])
    @username = @current_deploy_environment.publisher.username
    @app_name = @current_deploy_environment.app_name
  end

  def show
    pod_list = @current_deploy_environment.running_pods(@app_name, @username)
    log_files = @current_deploy_environment.log_files

    if pod_list.include?(params[:pod]) && log_files.include?(params[:log_file])
      pod_name = params[:pod]
      log_file = params[:log_file]
      lines = params[:lines].to_i
      respond_with log_output: `KUBE_MASTER=#{@current_deploy_environment.cluster.kube_api_server} ./bin/kube-status logs #{pod_name} #{log_file} #{lines} #{@username} 2>&1`
    else
      respond_with log_output: "Validation Error!"
    end
  end
end
