class ConfigFile < ApplicationRecord
	acts_as_paranoid
  belongs_to :deploy_environment
end
