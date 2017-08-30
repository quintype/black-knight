class EnvironmentsController < ApplicationController
  before_action :authenticate_user!, :unconfirmed_mfa!

  before_action :load_current_deploy_environment
  def load_current_deploy_environment
    @current_deploy_environment = current_user.deploy_environments.find(params[:environment_id])
  end

  def show
  end

  def migrations
  end

  def dispose
  end

  def migration_show
    @migration = current_user.migrations.find(params[:migration_id])
  end
end
