class Survey < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  has_many :inputs

end
