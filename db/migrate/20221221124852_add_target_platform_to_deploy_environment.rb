class AddTargetPlatformToDeployEnvironment < ActiveRecord::Migration[5.0]
  def change
    add_column :deploy_environments, :target_platform, :string
  end
end
