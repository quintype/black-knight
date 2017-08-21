class Api::MigrationsController < ApplicationController
  before_action :authenticate_user!,:unconfirmed_mfa!
  respond_to :json

  skip_before_filter :verify_authenticity_token

  def create
    migration_params = params[:migration]
    environment = current_deploy_environment(migration_params[:deploy_environment_id])
    migration = environment.new_migration(migration_params[:version], migration_params[:migration_command], current_user)
    if(migration.save)
      respond_with({migration: migration}, location: "/migration/#{migration.id}")
      DeployContainerJob.perform_later(migration.id, request.base_url, 'Migration')
    else
      respond_with migration
    end
  end

  def show
    respond_with migration: current_migration(params[:id])
  end
end
