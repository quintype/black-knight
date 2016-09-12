class AddDeletedAtToConfigFiles < ActiveRecord::Migration[5.0]
  def change
  	add_column :config_files, :deleted_at, :date
  end
end
