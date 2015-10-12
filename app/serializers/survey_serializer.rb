class SurveySerializer < ActiveModel::Serializer
  attributes :id, :code, :campaign_id, :title, :sensor_type, :threshold, :threshold_is_upper_limit
  has_many :inputs
end
