class ConfigFilesController < ApplicationController
  before_action :authenticate_user!

  def new
    @config_file = ConfigFile.new()
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
    @config_file = ConfigFile.new()
    @config_file.deploy_environment = current_user.deploy_environments.find(params[:config_file][:deploy_environment_id])
    @config_file.value = params[:config_file][:value]
    @config_file.path = params[:config_file][:path]
    if @config_file.save
      redirect_to action: "show", id: "#{@config_file.id}"
    else
      render action: "new"
    end
  end

  def update
    @config_file = current_user.config_files.find(params[:id])    
    @config_file.deploy_environment = current_user.deploy_environments.find(params[:config_file][:deploy_environment_id])
    @config_file.value = params[:config_file][:value]
    @config_file.path = params[:config_file][:path]
    if @config_file.save
      redirect_to action: "show", id: "#{@config_file.id}"
    else
      render action: "new"
    end
  end

  def destroy
    @config_file = current_user.config_files.find(params[:id])
    @current_deploy_environment = @config_file.deploy_environment
    @config_file.destroy
    redirect_to action: "index", deploy_environment_id: "#{@current_deploy_environment.id}"
  end

  def edit
    @config_file = current_user.config_files.find(params[:id])
  end
end
