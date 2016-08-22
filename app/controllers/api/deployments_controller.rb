class Api::DeploymentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  skip_before_filter :verify_authenticity_token

  def create
    deploy_params = params[:deployment]
    environment = current_user.deploy_environments.find(deploy_params[:deploy_environment_id])
    deployment = environment.new_deployment(deploy_params[:version], current_user)
    if(deployment.save)
      respond_with({deployment: deployment}, location: "/deploy/#{deployment.id}")
      post_to_slack(environment, deployment)
      DeployContainerJob.perform_later deployment.id
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
      DeployContainerJob.perform_later deployment.id
    else
      respond_with deployment
    end
  end

  private
  def post_to_slack(environment, deployment)
    #if ENV['RAILS_ENV'] != 'development'
      uri = URI('https://hooks.slack.com/services/your/hook/here')
      params = {channel: "#deploys", username: "#{current_user.name ||= current_user.email}", text: "Deploying #{environment.app_name} #{environment.name} with tag #{deployment.version}", icon_emoji: ":wrench:"}.to_json
      request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
      request.body = params
      Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http| http.request(request) }
    #end
  end
end
