class DeployEnvironment < ApplicationRecord
  belongs_to :publisher
  has_many :config_files

  def display_name
    "#{name} (#{publisher.name})"
  end

  def config_files_as_json
    config_files.inject({}) do |h, config_file|
      h[config_file.path] = config_file.value
      h
    end
  end
end
