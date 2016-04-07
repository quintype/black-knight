class AddScheduledByAndCancellationToDeployments < ActiveRecord::Migration[5.0]
  def change
    add_column :deployments, :scheduled_by_id, :integer
    add_column :deployments, :cancelled_at, :timestamp
    add_column :deployments, :cancelled_by_id, :integer
  end
end
