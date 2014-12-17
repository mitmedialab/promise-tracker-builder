class SurveySerializer < ActiveModel::Serializer
  attributes :id, :code, :campaign_id, :title
  has_many :inputs
end
