class AddRedeployOfToDeployments < ActiveRecord::Migration[5.0]
  def change
    add_reference :deployments, :redeploy_of, foreign_key: true
  end
end
