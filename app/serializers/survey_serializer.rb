class SurveySerializer < ActiveModel::Serializer
  attributes :id, :campaign_id, :title
  has_many :inputs
end
