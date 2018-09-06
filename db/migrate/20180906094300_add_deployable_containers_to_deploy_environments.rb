class AddDeployableContainersToDeployEnvironments < ActiveRecord::Migration[5.0]
  def change
    add_column :deploy_environments, :deployable_containers, :string
  end
end
