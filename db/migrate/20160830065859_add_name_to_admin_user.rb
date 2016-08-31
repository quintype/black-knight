class AddNameToAdminUser < ActiveRecord::Migration[5.0]
  def change
  	add_column :admin_users, :name, :string
  end
end
