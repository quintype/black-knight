class DeployContainerJob < DeploymentBaseJob
  queue_as :deployment

  attr_accessor :deployment

  def update_deployment(attrs)
    deployment.update!(attrs)
  end

  def perform(deployment_id, base_url, clazz = 'Deployment')
    @deployment = Deployment.find(deployment_id)
    build_container = BuildContainer.new(@deployment)

    if @deployment.buildable?
      update_deployment(status: "building",
                        deploy_tag: build_container.new_tag,
                        build_started: DateTime.now,
                        build_output: "")
      post_slack(deployment,base_url)
      result = build_container.build! { |op| update_deployment(build_output: deployment.build_output + op) }
      update_deployment(build_ended: DateTime.now,
                        build_status: result[:success] ? "success": "failed",
                        status: result[:success] ? "deploying" : "failed-build")

      post_slack(deployment,base_url)
      return deployment if not result[:success]
    end

    update_deployment(deploy_started: DateTime.now,
                      deploy_output: "",
                      status: "deploying")

    result = build_container.deploy! { |op|
        update_deployment(deploy_output: deployment.deploy_output + op)
    }

    update_deployment(deploy_ended: DateTime.now,
                      deploy_status: result[:success] ? "success": "failed",
                      status: result[:success] ? "success" : "failed-deploy")

    post_slack(deployment,base_url)
  end
end
