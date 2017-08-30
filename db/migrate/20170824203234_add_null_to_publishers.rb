class AddNullToPublishers < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :null, :boolean
  end
end
