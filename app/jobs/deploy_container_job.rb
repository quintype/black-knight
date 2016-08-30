class DeployContainerJob < ApplicationJob
  queue_as :default

  attr_reader :deployment

  def update_deployment(attrs)
    @deployment.update!(attrs)
    ActionCable.server.broadcast("deployment_#{@deployment.id}", attrs) rescue nil
  end

  def perform(deployment_id)
    @deployment = Deployment.find(deployment_id)
    build_container = BuildContainer.new(@deployment)
    if @deployment.buildable?
      update_deployment(status: "building",
                        deploy_tag: build_container.new_tag,
                        build_started: DateTime.now,
                        build_output: "")
      post_slack(deployment)
      result = build_container.build! { |op| update_deployment(build_output: deployment.build_output + op) }
      update_deployment(build_ended: DateTime.now,
                        build_status: result[:success] ? "success": "failed",
                        status: result[:success] ? "deploying" : "failed-build")

      post_slack(deployment)
      return deployment if not result[:success]
    end

    update_deployment(deploy_started: DateTime.now,
                      deploy_output: "",
                      status: "deploying")

    result = build_container.deploy! { |op| update_deployment(deploy_output: deployment.deploy_output + op) }
    update_deployment(deploy_ended: DateTime.now,
                      deploy_status: result[:success] ? "success": "failed",
                      status: result[:success] ? "success" : "failed-deploy")
    post_slack(deployment)
  end

  private
  def post_slack(deployment)
    user = deployment.scheduled_by
    environment = user.deploy_environments.find(deployment.deploy_environment_id)
    message = {"building" => "Building `#{environment.app_name}` `#{environment.name}` with tag `#{deployment.version}`",
               "success" => "Deployed `#{environment.app_name}` with tag `#{deployment.deploy_tag}`.",
               "deploying" => "Build successful. Deploying `#{environment.app_name}` `#{environment.name}` with tag `#{deployment.version}`",
               "failed-build" => "Build failed `#{environment.app_name}` `#{environment.name}` with tag `#{deployment.version}`",
               "failed-deploy" => "Deploy failed `#{environment.app_name}` with tag `#{deployment.deploy_tag}`"}
    if ENV['RAILS_ENV'] != 'development'
      uri = URI('https://hooks.slack.com/services/your/hook/here')
      params = {channel: "#deploys",
                username: "#{user.name||=user.email} (Black Knight)",
                text: message[deployment.status],
                icon_emoji: ":wrench:"}.to_json
      request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
      request.body = params
      Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http| http.request(request) }
    end
  end
end
