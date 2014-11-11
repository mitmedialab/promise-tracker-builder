class Tag < ActiveRecord::Base
  has_and_belongs_to_many :campaigns

  validates :label, uniqueness: true, presence: true
end
