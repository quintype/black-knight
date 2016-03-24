class DeployEnvironment < ApplicationRecord
  belongs_to :publisher

  def display_name
    "#{name} (#{publisher.name})"
  end
end
