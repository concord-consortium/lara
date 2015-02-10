module CRater::SettingsProviderFunctionality
  extend ActiveSupport::Concern
  included do
    has_one :c_rater_settings, as: :provider, class_name: 'CRater::Settings'
  end
end
