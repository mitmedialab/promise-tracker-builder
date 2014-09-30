class SurveySerializer < ActiveModel::Serializer
  attributes :id, :guid, :campaign_id, :title
  has_many :inputs
end
