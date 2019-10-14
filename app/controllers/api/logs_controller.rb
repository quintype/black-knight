class Api::LogsController < ApplicationController
  before_action :authenticate_user!,:unconfirmed_mfa!
  respond_to :json

  skip_before_action :verify_authenticity_token, only: [:scale]

  def show
    deploy_environment = current_user.deploy_environments.find(params[:id])

    if deploy_environment.running_pods.include?(params[:pod]) && deploy_environment.log_files.include?(params[:log_file])
      pod_name = params[:pod]
      log_file = params[:log_file]
      lines = params[:lines].to_i
      respond_with log_output: `KUBE_MASTER="#{deploy_environment.cluster.kube_api_server}" MULTIPLE_CONTAINER_PODS=#{deploy_environment.multi_container_pod.to_s} ./bin/kube-status logs #{pod_name} #{log_file} #{lines} #{deploy_environment.username} 2>&1`
    else
      respond_with log_output: "Validation Error!"
    end
  end
end
