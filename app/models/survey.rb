class Survey < ActiveRecord::Base
  has_many :inputs
  belongs_to :user

  validates :title, presence: true
  validates :status, presence: true

  STATUS =  ["editing", "active", "closed"]

end
