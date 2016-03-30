class AddRepositoryToDeployEnvironment < ActiveRecord::Migration[5.0]
  def change
    add_column :deploy_environments, :app_name, :string
    add_column :deploy_environments, :repository, :string
  end
end
