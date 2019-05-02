class AddMigrateWithSidecarToDeployEnvironments < ActiveRecord::Migration[5.0]
  def change
    add_column :deploy_environments, :migrate_with_sidecar, :boolean
  end
end
