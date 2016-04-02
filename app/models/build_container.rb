class BuildContainer
  attr_reader :old_tag, :new_tag, :config_files

  def initialize(deploy_env, deploy_tag)
    @deploy_env = deploy_env
    @old_tag = deploy_tag
    @new_tag = "#{deploy_env.publisher.username}-#{deploy_env.name}-" + DateTime.now.strftime("%Y%m%d%H%M%S")
    @config_files = deploy_env.config_files_as_json
  end

  def build!
    # These must be the first lines of the function, to ensure cleanup
    read_tar, write_tar = IO.pipe
    read_output, write_output = IO.pipe

    # Run the child process in separate thread so that we can close write
    thread = Thread.new do
      pid_result = system({"QT_ENV" => Rails.application.secrets.qt_environment},
                          "#{Rails.root}/bin/docker_build.sh", @deploy_env.publisher.username, @deploy_env.repository, old_tag, new_tag,
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
      pid_result = system({"KUBE_MASTER" => Rails.application.secrets.kube_master},
                          "#{Rails.root}/bin/docker_deploy.sh", @deploy_env.app_name, @deploy_env.repository, new_tag,
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

  def self.build_and_deploy!(deploy_env, deploy_tag)
    build_container = new(deploy_env, deploy_tag)
    record = Deployment.create!(deploy_environment: deploy_env,
                                status: "running",
                                version: build_container.old_tag,
                                configuration: build_container.config_files.to_json,
                                deploy_tag: build_container.new_tag)

    record.update!(build_started: DateTime.now)
    result = build_container.build! { |op| record.update!(build_output: record.build_output + op) }
    record.update!(build_ended: DateTime.now,
                   build_status: result[:success] ? "success": "failed",)

    return record if not record.build_status?

    record.update!(deploy_started: DateTime.now)
    result = build_container.deploy! { |op| record.update!(deploy_output: record.deploy_output + op) }
    record.update!(deploy_ended: DateTime.now,
                   deploy_status: result[:success] ? "success": "failed",)

    record
  end
end
