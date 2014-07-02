class Form < ActiveRecord::Base
  has_many :inputs
  belongs_to :user
end
