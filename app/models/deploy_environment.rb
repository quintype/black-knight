class DeployEnvironment < ApplicationRecord
  belongs_to :publisher
  has_many :config_files
  has_many :deployments
  belongs_to :cluster

  def display_name
    "#{name} (#{publisher.name})"
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

  def config_files_as_json
    config_files.inject({}) do |h, config_file|
      h[config_file.path] = config_file.value
      h
    end
  end
end
