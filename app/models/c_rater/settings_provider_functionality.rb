module CRater::SettingsProviderFunctionality
  extend ActiveSupport::Concern
  included do
    has_one :c_rater_item_settings, as: :provider, class_name: 'CRater::ItemSettings'
  end
end
