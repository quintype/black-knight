ActiveAdmin.register DeployEnvironment do
  permit_params :publisher_id, :name, :app_name, :repository, :disposable, :cluster_id, :migratable, :multi_container_pod, :deployable_containers, :target_platform

  filter :publisher
  filter :name
  filter :app_name
  filter :repository
  filter :cluster_id
  filter :disposable

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
      f.input :target_platform
    end
  f.actions
  end
end
