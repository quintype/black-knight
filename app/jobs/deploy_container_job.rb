class DeployContainerJob < ApplicationJob
  queue_as :default

  attr_reader :deployment

  def update_deployment(attrs)
    @deployment.update!(attrs)
  end

  def perform(deployment_id)
    @deployment = Deployment.find(deployment_id)
    build_container = BuildContainer.new(@deployment)

    update_deployment(status: "building",
                      deploy_tag: build_container.new_tag,
                      build_started: DateTime.now,
                      build_output: "")

    result = build_container.build! { |op| deployment.update!(build_output: deployment.build_output + op) }
    update_deployment(build_ended: DateTime.now,
                      build_status: result[:success] ? "success": "failed",
                      status: result[:success] ? "deploying" : "failed-build")

    return deployment if not result[:success]

    update_deployment(deploy_started: DateTime.now,
                      deploy_output: "")
    result = build_container.deploy! { |op| deployment.update!(deploy_output: deployment.deploy_output + op) }
    update_deployment(deploy_ended: DateTime.now,
                      deploy_status: result[:success] ? "success": "failed",
                      status: result[:success] ? "success" : "failed-deploy")
  end
end
