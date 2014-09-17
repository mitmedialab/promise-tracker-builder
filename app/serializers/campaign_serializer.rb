class CampaignSerializer < ActiveModel::Serializer
  attributes :title, :theme, :status, :start_date, :end_date
  has_one :survey
  has_many :tags
end
