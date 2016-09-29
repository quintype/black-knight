class ConfigFile < ApplicationRecord
	acts_as_paranoid
  belongs_to :deploy_environment

  before_save do |config_file|
    config_file.value = config_file.value.gsub("\r", "") if config_file.value
  end
end
