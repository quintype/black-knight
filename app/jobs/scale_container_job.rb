class ScaleContainerJob < ApplicationJob
  queue_as :default

  attr_reader :deploy_environment
  attr_reader :user

  def perform(deploy_environment_id, user_id, size)
    @deploy_environment = DeployEnvironment.find(deploy_environment_id)
    @user = User.find(user_id)

    if deploy_environment.disposable?
      PostToSlack.post("Scaling `#{deploy_environment.app_name}/#{deploy_environment.name}` to #{size}", user: user.name || user.email)
      system({"KUBE_MASTER" =>  @deploy_environment.cluster.kube_api_server}, "#{Rails.root}/bin/docker-scale.sh", deploy_environment.publisher.username, deploy_environment.repository, size.to_s, deploy_environment.app_name)
      PostToSlack.post("Successfully Scaled `#{deploy_environment.app_name}/#{deploy_environment.name}` to #{size}", user: user.name || user.email)
    end
  end
end
