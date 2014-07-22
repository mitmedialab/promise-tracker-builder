class Survey < ActiveRecord::Base
  has_many :inputs
  belongs_to :user

  STATUS =  ["editing", "active", "closed"]

end
