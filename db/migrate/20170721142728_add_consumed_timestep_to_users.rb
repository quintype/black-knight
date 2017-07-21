class AddConsumedTimestepToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :consumed_timestep, :integer
  end
end
