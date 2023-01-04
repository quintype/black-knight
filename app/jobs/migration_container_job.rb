class MigrationContainerJob < DeploymentBaseJob
  queue_as :migration
  attr_accessor :migration

  def perform(migration_id, base_url)
    @migration = Migration.find(migration_id)
    build_container = BuildContainer.new(migration)

    update_migration(status: "building",
                      deploy_tag: build_container.new_tag,
                      build_started: DateTime.now,
                      build_output: "")
    post_slack(migration, base_url)
    result = build_container.build! { |op| update_migration(build_output: migration.build_output + op) }
    update_migration(build_ended: DateTime.now,
                      build_status: result[:success] ? "success": "failed",
                      status: result[:success] ? "deploying" : "failed-build")

    post_slack(migration, base_url)
    return migration if not result[:success]

    update_migration(deploy_started: DateTime.now,
                      deploy_output: "",
                      status: "deploying")


    
    message = " Find logs in kibana.\n Select your app from index filter.\n Add a filter with kubernetes.pod.name is " + build_container.new_tag + "\n"
    result = build_container.deploy! { |op| update_migration(deploy_output: message) }
    update_migration(deploy_ended: DateTime.now,
     deploy_status: result[:success] ? "success": "failed",
     status: result[:success] ? "success": "failed-deploy" )
    update_migration(deploy_output: message)

    post_slack(migration, base_url)
  end

  def update_migration(attrs)
    migration.update!(attrs)
  end
end
