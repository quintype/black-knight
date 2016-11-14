class AddClusterToDeployEnvironment < ActiveRecord::Migration[5.0]
  def change
    add_reference :deploy_environments, :cluster, foreign_key: true
  end
end
