class AddDisposableToDeployEnvironments < ActiveRecord::Migration[5.0]
  def change
    add_column :deploy_environments, :disposable, :boolean
  end
end
