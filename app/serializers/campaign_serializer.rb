class CampaignSerializer < ActiveModel::Serializer
  attributes :title, :theme, :status, :start_date, :end_date
end
