class DeployContainerJob < ApplicationJob
  queue_as :default

  attr_reader :deployment

  def update_deployment(attrs)
    @deployment.update!(attrs)
    ActionCable.server.broadcast("deployment_#{@deployment.id}", attrs) rescue nil
  end

  def perform(deployment_id, user_name, app_name)
    @deployment = Deployment.find(deployment_id)
    build_container = BuildContainer.new(@deployment)
    if @deployment.buildable?
      update_deployment(status: "building",
                        deploy_tag: build_container.new_tag,
                        build_started: DateTime.now,
                        build_output: "")
      result = build_container.build! { |op| update_deployment(build_output: deployment.build_output + op) }
      update_deployment(build_ended: DateTime.now,
                        build_status: result[:success] ? "success": "failed",
                        status: result[:success] ? "deploying" : "failed-build")

      return deployment if not result[:success]
    end

    update_deployment(deploy_started: DateTime.now,
                      deploy_output: "",
                      status: "deploying")
    result = build_container.deploy! { |op| update_deployment(deploy_output: deployment.deploy_output + op) }
    update_deployment(deploy_ended: DateTime.now,
                      deploy_status: result[:success] ? "success": "failed",
                      status: result[:success] ? "success" : "failed-deploy")
    if deployment.status == "success"
      post_slack(app_name, user_name)
    end
  end

  private
  def post_slack(app_name, user_name)
    if ENV['RAILS_ENV'] != 'development'
      uri = URI('https://hooks.slack.com/services/your/hook/here')
      params = {channel: "#test", username: "#{user_name}", text: "Deployed #{app_name} with tag #{deployment.deploy_tag}. deploy_container_job.test", icon_emoji: ":wrench:"}.to_json
      request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
      request.body = params
      Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http| http.request(request) }
    end
  end
end
