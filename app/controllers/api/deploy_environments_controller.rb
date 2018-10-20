class Api::DeployEnvironmentsController < ApplicationController
  require "rx.rb" # Taken from the Rx repository, see https://github.com/rjbs/Rx/blob/master/ruby/Rx.rb
  require 'yaml'

  before_action :authenticate_user!, :unconfirmed_mfa!
  respond_to :json
  skip_before_action :verify_authenticity_token, only: [:scale]

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

  def load_more_deployments
    respond_with more_deployments: attributes_for_environment_page(current_user.deploy_environments.find(params[:deploy_environment_id]), params[:page])
  end

  SCHEMA_VALIDATION_SUPPORTED_EXT = ['.yml']

  def validate_config_file
    render status: 422, json: {error: {message: "Schema Validation not supported for given file format. Supported formats: #{SCHEMA_VALIDATION_SUPPORTED_EXT}"}} and return unless SCHEMA_VALIDATION_SUPPORTED_EXT.include?(File.extname(params["config_file_path"]))

    environment = current_user.deploy_environments.find(params[:deploy_environment_id])

    config_file = environment.config_files.select{ |config_file| config_file.path == params["config_file_path"] }&.first
    render status: 422, json: {error: {message: "No config_file found matching given path"}} and return unless config_file

    temp_schema_file_path = "/tmp/#{SecureRandom.uuid}_schema"
    result = system({}, "docker run --rm -v /tmp:/tmp #{environment.repository}:#{params["version"]} sh -c 'cp #{params["corresponding_schema_file_path"]} #{temp_schema_file_path}'")
    render status: 422, json: {error: {message: "File not found"}} and return unless result

    rx = Rx.new({ :load_core => true })
    schema = rx.make_schema(YAML.load_file(temp_schema_file_path))
    schema.check!(YAML.load(config_file.value))
  rescue Exception => e
    render status: 422, json: {error: {message: "Schema validation did not pass. #{e.message}"}}
  ensure
    File.delete(temp_schema_file_path) if temp_schema_file_path.present? && File.exist?(temp_schema_file_path)
  end
end
