class Survey < ActiveRecord::Base
  has_many :inputs
  belongs_to :user
end
