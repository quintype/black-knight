class CreateMigrations < ActiveRecord::Migration[5.0]
  def change
    create_table :migrations do |t|
      t.text :migration_command
      t.integer :deploy_environment_id
      t.string :status
      t.string :version
      t.text :configuration
      t.string :deploy_tag
      t.datetime :build_started
      t.datetime :build_ended
      t.string :build_status
      t.text :build_output
      t.datetime :deploy_started
      t.datetime :deploy_ended
      t.string :deploy_status
      t.text :deploy_output
      t.integer :scheduled_by_id
      t.datetime :cancelled_at
      t.integer :cancelled_by_id

      t.timestamps
    end
  end
end
