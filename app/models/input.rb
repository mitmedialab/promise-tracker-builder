class Input < ActiveRecord::Base
  belongs_to :survey
  serialize :options, JSON
end
