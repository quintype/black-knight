class ScaleContainerJob < ApplicationJob
  queue_as :default

  attr_reader :deploy_environment
  attr_reader :user

  def perform(deploy_environment_id, user_id, size)
    @deploy_environment = DeployEnvironment.find(deploy_environment_id)
    @user = User.find(user_id)

    if deploy_environment.disposable?
      post_slack("Scaling `#{deploy_environment.app_name}/#{deploy_environment.name}` to #{size}")
      system({"KUBE_MASTER" =>  @deploy_environment.cluster.kube_api_server}, "#{Rails.root}/bin/docker-scale.sh", deploy_environment.publisher.username, deploy_environment.repository, size.to_s, deploy_environment.app_name)
      post_slack("Successfully Scaled `#{deploy_environment.app_name}/#{deploy_environment.name}` to #{size}")
    end
  end

  private
  # This should be made into a separate class
  def post_slack(message)
    uri = URI('https://hooks.slack.com/services/your/hook/here')
    params = {channel: "#deploys",
              username: "#{user.name||=user.email} (Black Knight)",
              text: message,
              icon_emoji: ":wrench:"}.to_json
    request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
    request.body = params
    Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http| http.request(request) }
  end
end
