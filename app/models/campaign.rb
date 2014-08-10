class Campaign < ActiveRecord::Base
  belongs_to :user
  has_one :survey

  STATUS =  ['draft', 'active', 'closed']
end
