class Api::PublishersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def attributes_for_deploy_page(publishers)
    publishers.map do |publisher|
      publisher.attributes.merge(
        deploy_environments: publisher.deploy_environments.map do |deploy_environment|
          deploy_environment.attributes.merge(
            deployments: deploy_environment.deployments.latest.map do |deployment|
              deployment.attributes.slice("id", "version", "deploy_tag", "status")
            end
          )
        end
      )
    end
  end

  def index
    respond_with publishers: attributes_for_deploy_page(current_user.publishers(include: :deploy_environments))
  end
end
