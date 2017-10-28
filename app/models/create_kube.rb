class CreateKube
  attr_reader :deploy_env

  def initialize(deploy_env)
    @deploy_env = deploy_env
  end

  def create!
    cluster = @deploy_env.cluster
    publisher = @deploy_env.publisher.username
    app_name = @deploy_env.app_name
    repository = @deploy_env.repository
    `KUBE_MASTER=#{cluster.kube_api_server} SECRET=#{Rails.application.secrets.kube_registry_secret} ./bin/create-kube-config.sh create #{app_name} #{publisher} #{repository} 2>&1`
  end
end
