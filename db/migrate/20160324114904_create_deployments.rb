class CreateDeployments < ActiveRecord::Migration[5.0]
  def change
    create_table :deployments do |t|
      t.belongs_to :deploy_environment, foreign_key: true
      t.string :status, null: false
      t.string :version, null: false
      t.text :configuration, null: false

      t.timestamps
    end
  end
end
