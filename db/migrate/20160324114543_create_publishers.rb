class CreatePublishers < ActiveRecord::Migration[5.0]
  def change
    create_table :publishers do |t|
      t.integer :quintype_id_of_publisher, null: false
      t.string :name, null: false
      t.string :admin_email, null: false

      t.timestamps
    end
  end
end
