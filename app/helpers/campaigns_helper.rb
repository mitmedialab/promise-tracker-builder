module CampaignsHelper
  def campaign_themes
    I18n.t("activerecord.options.themes").map { |key, value| [ value, key ] }
  end
end