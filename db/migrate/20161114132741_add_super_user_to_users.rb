class AddSuperUserToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :super_user, :Boolean
  end
end
