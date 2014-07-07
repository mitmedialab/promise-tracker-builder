class Input < ActiveRecord::Base
  belongs_to :form
  serialize :options 
end
