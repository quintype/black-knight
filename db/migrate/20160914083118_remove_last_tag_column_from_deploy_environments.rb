class RemoveLastTagColumnFromDeployEnvironments < ActiveRecord::Migration[5.0]
  def change
  	remove_column :deploy_environments, :last_tag
  end
end
