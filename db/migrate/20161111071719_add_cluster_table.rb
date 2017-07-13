class AddClusterTable < ActiveRecord::Migration[5.0]
  def change
    create_table :clusters do |t|
      t.string :name, null: false, unique: true
      t.string :kube_api_server, null: false
      t.timestamps
    end
  end
end
