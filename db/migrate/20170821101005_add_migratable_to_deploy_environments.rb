class AddMigratableToDeployEnvironments < ActiveRecord::Migration[5.0]
  def change
    add_column :deploy_environments, :migratable, :boolean
  end
end
