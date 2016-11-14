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
    # These must be the first lines of the function, to ensure cleanup
    read_tar, write_tar = IO.pipe
    read_output, write_output = IO.pipe

    # Run the child process in separate thread so that we can close write
    thread = Thread.new do
      pid_result = system({"QT_ENV" => Rails.application.secrets.qt_environment, "BLACK_KNIGHT_DEPLOYMENT" => deployment.id.to_s},
                          "#{Rails.root}/bin/docker-build.sh", deploy_env.publisher.username, deploy_env.repository, old_tag, new_tag,
                          :in => read_tar, :out => write_output, :err => [:child, :out])
      write_output.close
      {success: pid_result}
    end

    # Write the tarball
    tarball_string = Tarball.new(config_files).to_s
    write_tar.write(tarball_string)
    write_tar.close

    # Stream output to listener, then exit with result
    PipeReader.new(read_output).read(100) { |o| yield o}

    thread.value
  ensure
    [read_tar, write_tar, read_output, write_output].each(&:close)
  end

  def deploy!
    read_output, write_output = IO.pipe

    # Run the child process in separate thread so that we can close write
    thread = Thread.new do
      pid_result = system({"KUBE_MASTER" => deploy_env.cluster.kube_api_server},
                          "#{Rails.root}/bin/docker-deploy.sh", deploy_env.publisher.username, deploy_env.repository, new_tag, deploy_env.app_name,
                          :out => write_output, :err => [:child, :out])
      write_output.close
      {success: pid_result}
    end

    # Stream output to listener, then exit with result
    PipeReader.new(read_output).read(100) { |o| yield o }
    thread.value
  ensure
    [read_output, write_output].each(&:close)
  end
end
