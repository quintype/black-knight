class AddMultiContainerPodToDeployEnvironments < ActiveRecord::Migration[5.0]
  def change
  	add_column :deploy_environments, :multi_container_pod, :boolean
  end
end
