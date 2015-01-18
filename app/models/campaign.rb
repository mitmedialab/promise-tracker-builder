class Campaign < ActiveRecord::Base
  belongs_to :user
  has_one :survey
  has_and_belongs_to_many :tags
  has_attached_file :image, default_url: '/assets/placeholder.jpg'

  validates :title, length: { minimum: 5 }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/ 

  STATUS =  ['draft', 'test', 'active', 'closed']

  def translated_themes
    I18n.t(:themes, :scope => 'campaigns.edit')
  end

  def clone
    clone = self.dup
    clone.tags = self.tags
    clone.update_attributes(
      status: 'draft',
      organizers: nil,
      anonymous: nil,
      start_date: nil,
      end_date: nil,
      image: nil
    )
    clone.save
    clone
  end

  def validate_goals
    self.goal.present? && 
    self.description.present? && 
    self.data_collectors.present? && 
    self.audience.present? &&  
    self.submissions_target.present?
  end

  def validate_profile
    self.organizers.present? || self.anonymous == true
  end

  def draft?
    self.status == 'draft' || self.status == 'test'
  end

  def get_latest_state
    if self.status == 'active'
      'collect'
    elsif self.status == 'test' || self.validate_profile
      'test'
    elsif self.survey || self.validate_goals
      'survey'
    else
      'edit'
    end
  end

end
