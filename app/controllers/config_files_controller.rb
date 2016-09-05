class ConfigFilesController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def index
  	@current_deploy_environment = current_user.deploy_environments.find(params[:deploy_environment_id])
  	@config_files = @current_deploy_environment.config_files

  end

  def show
  	@config_file = current_user.config_files.find(params[:id])
    @current_deploy_environment = @config_file.deploy_environment
  end

  def create
  end

  def update
  end

  def destroy
  end

  def edit
  end
end
