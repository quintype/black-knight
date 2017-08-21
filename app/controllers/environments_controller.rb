class EnvironmentsController < ApplicationController
  before_action :authenticate_user!,:unconfirmed_mfa!

  def show
    current_deploy_environment(params[:id])
  end

  def migrations
    current_deploy_environment(params[:environment_id])
  end

  def dispose
    current_deploy_environment(params[:environment_id])
  end

  def migration_show
    current_deploy_environment(params[:environment_id])
    @migration = current_migration(params[:migration_id])
  end
end
