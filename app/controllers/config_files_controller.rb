class ConfigFilesController < ApplicationController
  before_action :authenticate_user!,:unconfirmed_mfa!

  before_action :load_current_environment
  def load_current_environment
    @current_deploy_environment = current_user.deploy_environments.find(params[:environment_id])
  end

  def new
    @config_file = @current_deploy_environment.config_files.new
  end

  def index
  	@config_files = @current_deploy_environment.config_files
  end

  def show
  	@config_file = @current_deploy_environment.config_files.find(params[:id])
  end

  def create
    @config_file = @current_deploy_environment.config_files.build(value: params[:config_file][:value], path: params[:config_file][:path])
    if @config_file.save
      redirect_to action: "show", id: "#{@config_file.id}"
    else
      render action: "new"
    end
  end

  def update
    @config_file = @current_deploy_environment.config_files.find(params[:id])
    if @config_file.update(value: params[:config_file][:value], path: params[:config_file][:path])
      redirect_to action: "show", id: "#{@config_file.id}"
    else
      render action: "new"
    end
  end

  def destroy
    @config_file = @current_deploy_environment.config_files.find(params[:id])
    @config_file.destroy
    redirect_to action: "index", deploy_environment_id: "#{@current_deploy_environment.id}"
  end

  def edit
    @config_file = @current_deploy_environment.config_files.find(params[:id])
  end
end
