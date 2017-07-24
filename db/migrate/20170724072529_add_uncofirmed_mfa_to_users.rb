class AddUncofirmedMfaToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :unconfirmed_mfa, :boolean
  end
end
