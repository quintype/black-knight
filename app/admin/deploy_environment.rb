ActiveAdmin.register DeployEnvironment do
  permit_params :publisher_id, :name, :app_name, :repository, :disposable, :cluster_id

  filter :publisher_id
  filter :name
  filter :app_name
  filter :repository
  filter :cluster_id
  filter :disposable

end
