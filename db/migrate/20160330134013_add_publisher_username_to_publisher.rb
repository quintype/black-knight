class AddPublisherUsernameToPublisher < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :username, :string
  end
end
