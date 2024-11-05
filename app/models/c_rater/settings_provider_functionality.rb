module CRater::SettingsProviderFunctionality
  extend ActiveSupport::Concern
  included do |base|
    has_one :c_rater_item_settings, as: :provider, class_name: 'CRater::ItemSettings'
    delegate  :max_score, to: :c_rater_item_settings, allow_nil: true

    base.prepend InstanceMethods
    class << base
      def import_with_c_rater(import_hash)
        import_embeddable = self.import_without_c_rater(import_hash.except(:item_settings))
        if import_hash[:item_settings]
          item_settings = CRater::ItemSettings.import(import_hash[:item_settings])
          item_settings.provider = import_embeddable
          item_settings.save!(validate: false)
        end
        import_embeddable
      end
    end
  end

  module InstanceMethods
    def duplicate
      copy = super
      if c_rater_item_settings
        item_settings = c_rater_item_settings.duplicate
        item_settings.provider = copy
        item_settings.save!(validate: false)
      end
      copy
    end

    def export
      export_json = super
      if c_rater_item_settings
        export_json[:item_settings] = c_rater_item_settings.export
      end
      export_json
    end
  end
end

