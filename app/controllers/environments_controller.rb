class EnvironmentsController < ApplicationController
  before_action :authenticate_user!

  def show
    @current_deploy_environment = current_user.deploy_environments.find(params[:id])
  end

  def dispose
    @current_deploy_environment = current_user.deploy_environments.find(params[:environment_id])
  end
end
