class DeploymentChannel < ApplicationCable::Channel
  def subscribed
    stream_from "deployment_#{params[:deployment_id]}"
  end
end
