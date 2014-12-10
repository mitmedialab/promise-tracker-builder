class Campaign < ActiveRecord::Base
  belongs_to :user
  has_one :survey
  has_and_belongs_to_many :tags

  validates :title, length: { minimum: 3 }

  STATUS =  ['draft', 'active', 'closed']

  def translated_themes
    I18n.t(:themes, :scope => 'campaigns.edit')
  end

  def clone
    clone = self.dup
    clone.tags = self.tags
    clone.update_attribute(:status, 'draft')
    clone
  end

  def validate_public_page
  end

end
