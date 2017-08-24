# This class is hacky. Need to figure out how to test this
class BuildContainer
  attr_reader :deployment, :new_tag

  def deploy_env
    deployment.deploy_environment
  end

  def old_tag
    deployment.version
  end

  def config_files
    JSON.parse(deployment.configuration)
  end

  def initialize(deployment)
    @deployment = deployment
    @new_tag = deployment.new_deploy_tag
  end

  def build!
    shell = RunShell.new({"QT_ENV" => Rails.application.secrets.qt_environment, "BLACK_KNIGHT_DEPLOYMENT" => deployment.id.to_s},
                         "#{Rails.root}/bin/docker-build.sh", deploy_env.publisher.username, deploy_env.repository, old_tag, new_tag)
    tarball_string = Tarball.new(config_files).to_s
    shell.stdin.write(tarball_string)
    shell.stdin.close
    shell.execute! { |o| yield o }
  end

  def deploy!
    RunShell.execute!({"KUBE_MASTER" => deploy_env.cluster.kube_api_server}, "#{Rails.root}/bin/#{deployment.execute_command}",
                      deploy_env.publisher.username, deploy_env.repository, new_tag, deploy_env.app_name,
                      *deployment.execute_arguments) { |o| yield o }
  end
end
