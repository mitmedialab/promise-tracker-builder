class Survey < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  has_many :inputs

  validates :title, presence: true
  validates :status, presence: true

  STATUS =  ['draft', 'active', 'closed']

end
