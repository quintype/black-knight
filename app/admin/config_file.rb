ActiveAdmin.register ConfigFile do
  permit_params :deploy_environment_environment, :path, :value 
end
