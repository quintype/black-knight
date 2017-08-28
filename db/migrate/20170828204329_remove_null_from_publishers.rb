class RemoveNullFromPublishers < ActiveRecord::Migration[5.0]
  def change
    remove_column :publishers, :null
  end
end
