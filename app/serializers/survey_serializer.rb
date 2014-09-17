class SurveySerializer < ActiveModel::Serializer
  attributes :id, :guid, :campaign_id
  has_many :inputs
end
