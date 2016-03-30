class AddDeployFieldsToDeployments < ActiveRecord::Migration[5.0]
  def change
    add_column :deployments, :deploy_started, :timestamp
    add_column :deployments, :deploy_ended, :timestamp
    add_column :deployments, :deploy_status, :string
    add_column :deployments, :deploy_output, :text
  end
end
