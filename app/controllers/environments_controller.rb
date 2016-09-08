class EnvironmentsController < ApplicationController
  before_action :authenticate_user!

  def show
    @current_deploy_environment = current_user.deploy_environments.find(params[:id])
  end
end
