class BuildContainer
  attr_reader :old_tag, :new_tag, :config_files

  def initialize(deploy_env, deploy_tag)
    @deploy_env = deploy_env
    @old_tag = deploy_tag
    @new_tag = "#{deploy_env.publisher.username}-#{deploy_env.name}-" + DateTime.now.strftime("%Y%m%d%H%M%S")
    @config_files = deploy_env.config_files_as_json
  end

  def build!
    read_tar, write_tar = IO.pipe
    read_output, write_output = IO.pipe

    thread = Thread.new do
      pid_result = system({"QT_ENV" => Rails.application.secrets.qt_environment},
                          "#{Rails.root}/bin/docker_build.sh", @deploy_env.publisher.username, @deploy_env.repository, old_tag, new_tag,
                          :in => read_tar, :out => write_output, :err => [:child, :out])
      write_output.close
      {success: pid_result}
    end

    tarball_string = Tarball.new(config_files).to_s
    write_tar.write(tarball_string)
    write_tar.close

    PipeReader.new(read_output).read(100) { |o| yield o}
    thread.value
  ensure
    read_tar.close rescue nil
    write_tar.close rescue nil
    read_output.close rescue nil
    write_output.close rescue nil
  end

  def deploy!
    read_output, write_output = IO.pipe

    thread = Thread.new do
      pid_result = system({"KUBE_MASTER" => Rails.application.secrets.kube_master},
                          "#{Rails.root}/bin/docker_deploy.sh", @deploy_env.app_name, @deploy_env.repository, new_tag,
                          :out => write_output, :err => [:child, :out])
      write_output.close
      {success: pid_result}
    end

    PipeReader.new(read_output).read(100) { |o| yield o }
    thread.value
  ensure
    write_output.close rescue nil
    read_output.close rescue nil
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
