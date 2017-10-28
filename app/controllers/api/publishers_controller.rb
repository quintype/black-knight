class Api::PublishersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json ,:only => [:show, :create, :update]


  skip_before_filter :verify_authenticity_token

  def show
      respond_with publisher: Publisher.find(params[:id])
  end

  def create
      render json:  { publisher: Publisher.create!(quintype_id_of_publisher: params[:quintype_id_of_publisher], name: params[:name], admin_email: params[:admin_email], username: params[:username]) }
  end

end
