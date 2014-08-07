class Campaign < ActiveRecord::Base
  belongs_to :user
  has_one :survey

end
