class Migration < ApplicationRecord
  belongs_to :deploy_environment

  belongs_to :scheduled_by, class_name: "User"
  belongs_to :cancelled_by, class_name: "User"

  has_one :publisher, through: :deploy_environment

  validate :migration_command_is_an_array!

  scope :latest, -> { order("id desc").limit(5) }

  def attributes
    super.merge(scheduled_by: scheduled_by, cancelled_by: cancelled_by, buildable?: true)
  end

  def execute_command
    "docker-deploy.sh"
  end

  def execute_arguments
    JSON.parse(migration_command)
  end

  def buildable?
    true
  end

  def new_deploy_tag
    "#{deploy_environment.publisher.username}-#{deploy_environment.name}-migrate-" + DateTime.now.strftime("%Y%m%d%H%M%S")
  end

  def migration_command_is_an_array!
    command = JSON.parse(migration_command)
    errors.add(:migration_command, "is not an array") and return unless command.is_a? Array
    errors.add(:migration_command, "is empty") and return if command.empty?
    errors.add(:migration_command, "is invalid") and return if command[0].blank?
  end
end
