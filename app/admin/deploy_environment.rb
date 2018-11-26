ActiveAdmin.register DeployEnvironment do
  permit_params :publisher_id, :name, :app_name, :repository, :disposable, :cluster_id, :migratable, :multi_container_pod, :deployable_containers

  filter :publisher
  filter :name
  filter :app_name
  filter :repository
  filter :cluster_id
  filter :disposable

    begin
      before_destroy do |deploy_environment|
        if deploy_environment
          if not deploy_environment.deployments.empty?
            deploy_environment.deployments.delete_all
          end

          if not deploy_environment.config_files.empty?
            deploy_environment.config_files.delete_all!
          end
        end
      end
    rescue Exception => e
      raise e
    end

  form do |f|
    f.inputs "User Publisher Link" do
      f.input :publisher, collection: Publisher.all.sort_by { |publisher|  publisher.name }
      f.input :cluster
      f.input :name
      f.input :app_name
      f.input :repository
      f.input :disposable
      f.input :migratable
      f.input :multi_container_pod
      f.input :deployable_containers
    end
  f.actions
  end
end
