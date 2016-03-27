class Api::PublishersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    respond_with publishers: current_user.publishers(include: :deploy_environments)
  end
end
