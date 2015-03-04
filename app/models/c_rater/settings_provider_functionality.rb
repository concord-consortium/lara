module CRater::SettingsProviderFunctionality
  extend ActiveSupport::Concern
  included do |base|
    has_one :c_rater_item_settings, as: :provider, class_name: 'CRater::ItemSettings'
    
    alias_method_chain :duplicate, :c_rater
    
    alias_method_chain :export, :c_rater
    
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
      alias_method_chain :import, :c_rater
    end
    
  end
  
  def duplicate_with_c_rater
    copy = duplicate_without_c_rater
    if self.c_rater_item_settings
      item_settings = self.c_rater_item_settings.duplicate
      item_settings.provider = copy
      item_settings.save!(validate: false)
    end
    copy
  end
 
  def export_with_c_rater
    export_json = export_without_c_rater
    if self.c_rater_item_settings
        export_json[:item_settings] = self.c_rater_item_settings.export
    end
    export_json
  end
end
