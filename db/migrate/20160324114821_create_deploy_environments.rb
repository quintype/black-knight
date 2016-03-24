class CreateDeployEnvironments < ActiveRecord::Migration[5.0]
  def change
    create_table :deploy_environments do |t|
      t.belongs_to :publisher, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
