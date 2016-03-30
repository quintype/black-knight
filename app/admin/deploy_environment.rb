ActiveAdmin.register DeployEnvironment do
  permit_params :publisher_id, :name, :app_name, :repository
end
