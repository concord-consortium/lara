class AddFillAvailableSpaceToMwInteractives < ActiveRecord::Migration

  class MwInteractive < ActiveRecord::Base
    ASPECT_RATIO_DEFAULT_WIDTH = 576
    ASPECT_RATIO_DEFAULT_HEIGHT =  435
    ASPECT_RATIO_DEFAULT_METHOD = 'DEFAULT'
    ASPECT_RATIO_MANUAL_METHOD  = 'MANUAL'
    ASPECT_RATIO_MAX_METHOD = 'MAX'

    def is_codap_scaled_document
      # https://regexr.com/40h8k
      codap_scaling_regex = /http.+document-store.+codap\.concord.+&scaling/i
      return self.url && self.url.match(codap_scaling_regex)
    end

    def has_manually_specified_aspect_ratio
      if (self.native_width  != ASPECT_RATIO_DEFAULT_WIDTH)  ||
         (self.native_width  != ASPECT_RATIO_DEFAULT_HEIGHT)
          return true
      end
      return false
    end

    def set_aspect_ratio_method
      new_method=MwInteractive::ASPECT_RATIO_DEFAULT_METHOD
      if has_manually_specified_aspect_ratio
        unless is_codap_scaled_document
          new_method = MwInteractive::ASPECT_RATIO_MANUAL_METHOD
        end
      end
      if (self.aspect_ratio_method != new_method)
        self.update_attribute(:aspect_ratio_method, new_method)
      end
    end
  end

  def up
    add_column :mw_interactives, :aspect_ratio_method, :string,
    default: MwInteractive::ASPECT_RATIO_DEFAULT_METHOD

    MwInteractive.find_each(batch_size: 25) do |interactive|
      interactive.set_aspect_ratio_method
    end
  end

  def down
    remove_column :mw_interactives, :aspect_ratio_method
  end

end
