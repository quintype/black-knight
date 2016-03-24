class CreateConfigFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :config_files do |t|
      t.belongs_to :deploy_environment, foreign_key: true
      t.string :path, null: false
      t.text :value, null: false

      t.timestamps
    end
  end
end
