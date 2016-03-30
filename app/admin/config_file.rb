ActiveAdmin.register ConfigFile do
  permit_params :deploy_environment_id, :path, :value
end
