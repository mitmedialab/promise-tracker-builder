module CampaignsHelper
  def campaign_themes
    I18n.t("campaigns.edit.themes").map { |key, value| [ value, key ] }
  end
end