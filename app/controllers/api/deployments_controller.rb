class Api::DeploymentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    respond_with deployment: current_user.deployments.find(params[:id])
  end
end
