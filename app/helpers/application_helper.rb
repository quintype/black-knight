module ApplicationHelper
  def publishers
    if current_user.super_user?
      @publishers ||= Publisher.includes(:deploy_environments)
    else
      @publishers ||= current_user.publishers.includes(:deploy_environments)
    end
  end

  def current_publisher_id
    current_deploy_environment.try(:publisher_id)
  end

  def current_deploy_environment
    @current_deploy_environment ||= current_user.publishers.flat_map(&:deploy_environments).first
  end
end
