class AddDefaultValueToMultiContainerPod < ActiveRecord::Migration[5.0]
  def change
    change_column :deploy_environments, :multi_container_pod, :boolean, :default => false
  end
end
