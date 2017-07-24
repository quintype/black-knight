class EnvironmentsController < ApplicationController
  before_action :authenticate_user!,:unconfirmed_mfa?

  def show
    current_deploy_environment(params[:id])
  end

  def dispose
    current_deploy_environment(params[:environment_id])
  end
end
