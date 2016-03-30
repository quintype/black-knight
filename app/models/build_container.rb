class BuildContainer
  attr_reader :old_tag, :new_tag, :config_files

  def initialize(deploy_env, deploy_tag)
    @deploy_env = deploy_env
    @old_tag = deploy_tag
    @new_tag = "#{deploy_env.publisher.username}-#{deploy_env.name}-" + DateTime.now.strftime("%Y%m%d%H%M%S")
    @config_files = deploy_env.config_files_as_json
  end

  def build!
    tarball_string = Tarball.new(config_files).to_s

    read_tar, write_tar = IO.pipe
    write_tar.write(tarball_string)
    write_tar.close

    read_output, write_output = IO.pipe

    pid_result = system({"QT_ENV" => Rails.application.secrets.qt_environment},
                        "#{Rails.root}/bin/awesome", @deploy_env.publisher.username, @deploy_env.repository, old_tag, new_tag,
                        :in => read_tar, :out => write_output, :err => [:child, :out])

    read_tar.close
    write_output.close

    output = read_output.read
    read_output.close
    {success: pid_result, output: output}
  end

  def deploy!
    read_output, write_output = IO.pipe

    pid_result = system({"KUBE_MASTER" => Rails.application.secrets.kube_master},
                        "#{Rails.root}/bin/foobar", @deploy_env.app_name, @deploy_env.repository, new_tag,
                        :out => write_output, :err => [:child, :out])

    write_output.close

    output = read_output.read
    read_output.close
    {success: pid_result, output: output}
  end

  def self.build_and_deploy!(deploy_env, deploy_tag)
    build_container = new(deploy_env, deploy_tag)
    record = Deployment.create!(deploy_environment: deploy_env,
                                status: "running",
                                version: build_container.old_tag,
                                configuration: build_container.config_files.to_json,
                                deploy_tag: build_container.new_tag)

    build_started = DateTime.now
    result = build_container.build!
    build_ended = DateTime.now
    record.update!(build_started: build_started,
                   build_ended: build_ended,
                   build_status: result[:success] ? "success": "failed",
                   build_output: result[:output])

    return record if not record.build_status?

    deploy_started = DateTime.now
    result = build_container.deploy!
    deploy_ended = DateTime.now
    record.update!(deploy_started: deploy_started,
                   deploy_ended: deploy_ended,
                   deploy_status: result[:success] ? "success": "failed",
                   deploy_output: result[:output])

    record
  end
end
