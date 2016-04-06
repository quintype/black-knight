module ApplicationHelper
  def publishers
    @publishers ||= current_user.publishers.includes(:deploy_environments)
  end

  def current_publisher_id
    current_deploy_environment.try(:publisher_id)
  end

  def current_deploy_environment
    @current_deploy_environment ||= current_user.publishers.flat_map(&:deploy_environments).first
  end
end
