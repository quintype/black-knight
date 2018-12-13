class AddDeletedAtToDeployments < ActiveRecord::Migration[5.0]
  def change
        add_column :deployments, :deleted_at, :date
  end
end
