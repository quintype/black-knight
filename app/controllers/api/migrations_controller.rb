class Api::MigrationsController < ApplicationController
  before_action :authenticate_user!,:unconfirmed_mfa!
  respond_to :json

  skip_before_action :verify_authenticity_token

  def create
    migration_params = params[:migration]
    environment = current_user.deploy_environments.find(migration_params[:deploy_environment_id])
    migration = environment.new_migration(migration_params[:version], migration_params[:migration_command], current_user)
    if(migration.save)
      respond_with({migration: migration}, location: "/migration/#{migration.id}")
      DeployContainerJob.perform_later(migration.id, request.base_url, 'Migration')
    else
      respond_with migration
    end
  end

  def show
    respond_with migration: current_user.migrations.find(params[:id])
  end

  # FIXME: Tejas has given up. This code needs cleanup, ASAP
  def destroy
    migration = current_user.migrations.find(params[:id])
    cluster = migration.deploy_environment.cluster
    deploy_env = migration.deploy_environment
    render json: {message: `KUBE_MASTER=#{cluster.kube_api_server} ABORT=1 ./bin/docker-migration.sh #{deploy_env.publisher.username} #{deploy_env.repository} #{migration.deploy_tag} #{deploy_env.app_name} 2>&1`}
  end
end
