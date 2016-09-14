class AddLastTagToDeployEnvironment < ActiveRecord::Migration[5.0]
  def change
  	add_column :deploy_environments, :last_tag, :string
  end
end
