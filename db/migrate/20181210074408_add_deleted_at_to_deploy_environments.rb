class AddDeletedAtToDeployEnvironments < ActiveRecord::Migration[5.0]
  def change
        add_column :deploy_environments, :deleted_at, :date
  end
end
