class DeployEnvironment < ApplicationRecord
  belongs_to :publisher
  has_many :config_files
  has_many :deployments
  has_many :migrations
  belongs_to :cluster

  def display_name
    "#{name} (#{publisher.name})"
  end

  def username
    publisher.username
  end

  def new_deployment(version, user)
    deployments.new(status: "pending",
                    version: version,
                    configuration: config_files_as_json.to_json,
                    scheduled_by: user)
  end

  def new_redeployment(deployment, user)
    deployments.new(status: "pending",
                    version: "redeploy",
                    redeploy_of: deployment,
                    configuration: deployment.configuration,
                    deploy_tag: deployment.deploy_tag,
                    scheduled_by: user)
  end

  def new_migration(version, command, user)
    migrations.new(status: "pending",
                   migration_command: command.to_json,
                   version: version,
                   configuration: config_files_as_json.to_json,
                   scheduled_by: user)
  end

  def config_files_as_json
    config_files.inject({}) do |h, config_file|
      h[config_file.path] = config_file.value
      h
    end
  end

  def running_pods
    `KUBE_MASTER=#{cluster.kube_api_server} ./bin/kube-status gp #{app_name} #{username} 2>&1`.split("\n")
  end

  def log_files
    Rails.application.config.log_files["paths"]
  end
end
