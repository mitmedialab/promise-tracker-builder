class CampaignSerializer < ActiveModel::Serializer
  attributes :title, :description, :theme, :status, :start_date, :end_date
  has_one :survey
  has_many :tags
end
