class Api::DeployEnvironmentsController < ApplicationController
  require "rx.rb" # Taken from the Rx repository, see https://github.com/rjbs/Rx/blob/master/ruby/Rx.rb
  require 'yaml'

  before_action :authenticate_user!, :unconfirmed_mfa!
  respond_to :json

  skip_before_action :verify_authenticity_token, only: [:scale, :clone_as_pr, :destroy]

  # FIXME: Terrible modelling, this should be as_json(include:). Or use jbuilder.
  def attributes_for_environment_page(deploy_environment, page=nil)
    if page
      deploy_environment.deployments.all.reverse_order.page(page).per(5).map {|deployment|
        deployment.attributes.slice("id", "version", "deploy_tag", "status")
      }
    else
      deploy_environment.attributes.merge(
        deployments: deploy_environment.deployments.latest.map { |deployment|
          deployment.attributes.slice("id", "version", "deploy_tag", "status")
        },
        migrations: deploy_environment.migrations.latest.map { |migration|
          migration.attributes.slice("id", "version", "deploy_tag", "status", "migration_command")
        }
      )
    end
  end

  def show
    respond_with deploy_environment: attributes_for_environment_page(current_user.deploy_environments.find(params[:id]))
  end

  def scale
    deploy_environment = current_user.deploy_environments.find(params[:deploy_environment_id])
    size = params[:size]
    if(deploy_environment.disposable? && size < 4)
      ScaleContainerJob.perform_later(deploy_environment.id, current_user.id, size)
      render status: 201, json: {"state": "accepted"}
    else
      render status: 422, json: {error: {message: "Cannot Scale This Container"}}
    end
  end

  def index
    if(params['publisher_id'])
        render status: 200, json: current_user.publishers.find(params['publisher_id']).deploy_environments
    else
        render status: 200, json: current_user.deploy_environments.order("created_at DESC").limit(30)
    end
  end

  def load_more_deployments
    respond_with more_deployments: attributes_for_environment_page(current_user.deploy_environments.find(params[:deploy_environment_id]), params[:page])
  end

  def validate_config_file
    render status: 422, json: {error: {message: "Schema Validation not supported for given file format. Supported formats: #{SCHEMA_VALIDATION_SUPPORTED_EXT}"}} and return unless schema_validation_supported_format?

    render status: 422, json: {error: {message: "No config_file found matching given path"}} and return unless config_file

    render status: 422, json: {error: {message: "File not found"}} and return unless schema_file_tmp_path

    rx = Rx.new({ :load_core => true })
    schema = rx.make_schema(YAML.load_file(schema_file_tmp_path))
    schema.check!(YAML.load(config_file.value))
  rescue Exception => e
    render status: 422, json: {error: {message: "Schema validation did not pass. #{e.message}"}}
  ensure
    system({}, "docker run --rm -v /tmp:/tmp #{current_environment.repository}:#{params["version"]} sh -c 'rm #{schema_file_tmp_path}'")
  end

  def clone_as_pr
     new_deploy_environment              = current_environment.amoeba_dup
     new_deploy_environment.assign_attributes(name: pr_deploy_environment_name,
                                              app_name: pr_deploy_environment_name,
                                              publisher_id: params[:pr_publisher_id])

    if new_deploy_environment.save
        render json: new_deploy_environment
    else
        render status: 422, json: {error: {message: "Error cloning deploy environment"}}
    end
  end

  def destroy
     current_user.deploy_environments.find(params[:id]).destroy
     render status: 204
  end

  private

  def pr_deploy_environment_name
    temp_environment_name = current_environment.name.split("-")
    temp_environment_name[temp_environment_name.length - 1] = params[:pr_num].to_s
    temp_environment_name.join("-")
  end

  def schema_file_tmp_path
    return @schema_file_tmp_path if defined? @schema_file_tmp_path
    @schema_file_tmp_path = "/tmp/#{SecureRandom.uuid}_schema"
    result = system({}, "docker run --rm -v /tmp:/tmp #{current_environment.repository}:#{params["version"]} sh -c 'cp #{params["corresponding_schema_file_path"]} #{@schema_file_tmp_path}'")
    result ? @schema_file_tmp_path : ""
  end

  SCHEMA_VALIDATION_SUPPORTED_EXT = ['.yml']

  def schema_validation_supported_format?
    SCHEMA_VALIDATION_SUPPORTED_EXT.include?(File.extname(params["config_file_path"]))
  end

  def config_file
    @config_file ||= current_environment.config_files.select{ |config_file| config_file.path == params["config_file_path"] }&.first
  end

  def current_environment
    @current_environment ||= current_user.deploy_environments.find(params[:deploy_environment_id])
  end
end
