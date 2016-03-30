class AddBuildFieldsToDeployments < ActiveRecord::Migration[5.0]
  def change
    add_column :deployments, :deploy_tag, :string
    add_column :deployments, :build_started, :timestamp
    add_column :deployments, :build_ended, :timestamp
    add_column :deployments, :build_status, :string
    add_column :deployments, :build_output, :text
  end
end
