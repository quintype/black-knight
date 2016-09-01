class ConfigFilesController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def index
  	@current_deploy_environment = current_user.deploy_environments.find(params[:deploy_environment_id])
  end

  def show
  	@config_file = ConfigFile.find(params[:config_file_id])
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
