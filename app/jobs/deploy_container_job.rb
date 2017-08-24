class DeployContainerJob < ApplicationJob
  queue_as :default

  attr_reader :deployment

  def update_deployment(attrs)
    @deployment.update!(attrs)
  end

  # This loads the deployment or migration as needed
  def load_deployable(clazz, deployment_id)
    case(clazz)
    when 'Deployment'
      Deployment.find(deployment_id)
    when 'Migration'
      Migration.find(deployment_id)
    else
      raise "Unknown deployment type #{clazz}"
    end
  end

  def perform(deployment_id, base_url, clazz = 'Deployment')
    @deployment = load_deployable(clazz, deployment_id)
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

    result = build_container.deploy! { |op| update_deployment(deploy_output: deployment.deploy_output + op) }
    update_deployment(deploy_ended: DateTime.now,
                      deploy_status: result[:success] ? "success": "failed",
                      status: result[:success] ? "success" : "failed-deploy")
    post_slack(deployment,base_url)
  end

  private
  # This should be made into a separate class
  def post_slack(deployment, base_url, channel="#deploy-#{Rails.application.secrets[:qt_environment]}")
    user = deployment.scheduled_by
    environment = deployment.deploy_environment
    messages = {"building" => "Deploying `#{environment.app_name}/#{environment.name}` with tag `#{deployment.version}`",
                "success" => "Deployed `#{environment.app_name}/#{environment.name}` with tag `#{deployment.deploy_tag}`.",
                "failed-build" => "Build failed `#{environment.app_name}/#{environment.name}` <#{base_url}/deploy/#{deployment.id}|More Details>",
                "failed-deploy" => "Deploy failed `#{environment.app_name}/#{environment.name}` <#{base_url}/deploy/#{deployment.id}|More Details>"}

    if message = messages[deployment.status]
      uri = URI(Rails.application.secrets[:slack_hook])
      params = {channel: channel,
                username: "#{user.name||=user.email} (Black Knight)",
                text: message,
                icon_emoji: ":wrench:"}.to_json
      request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
      request.body = params
      Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http| http.request(request) }
    end
  end
end
