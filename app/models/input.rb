class Input < ActiveRecord::Base
  belongs_to :survey
  serialize :options, JSON

  validates :input_type, presence: true
  validates :survey_id, presence: true
end
