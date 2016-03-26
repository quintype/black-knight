class DeployController < ApplicationController
  def index
    puts current_user
    render html: "foobar"
  end
end
