class Campaign < ActiveRecord::Base
  belongs_to :user
  has_one :survey
  has_and_belongs_to_many :tags

  STATUS =  ['draft', 'active', 'closed']

  def translated_themes
    I18n.t(:themes, :scope => 'campaigns.edit')
  end

end
