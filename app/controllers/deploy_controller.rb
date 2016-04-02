class DeployController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    @deployment = current_user.deployments.find(params[:deployment_id])
  end
end
