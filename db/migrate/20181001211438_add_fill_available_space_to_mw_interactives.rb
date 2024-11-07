class AddFillAvailableSpaceToMwInteractives < ActiveRecord::Migration[5.1]
  ASPECT_RATIO_DEFAULT_WIDTH = 576
  ASPECT_RATIO_DEFAULT_HEIGHT =  435
  ASPECT_RATIO_DEFAULT_METHOD = 'DEFAULT'
  ASPECT_RATIO_MANUAL_METHOD  = 'MANUAL'

  def up
    add_column :mw_interactives, :aspect_ratio_method, :string,
    default: MwInteractive::ASPECT_RATIO_DEFAULT_METHOD

    # 1. Update ALL documents to use "DEFAULT"
    MwInteractive.update_all("aspect_ratio_method = 'DEFAULT'")

    # 2. Documents that specify native_width or native_height set to anything beside default values: MANUAL
    like_has_custom_sizes = "native_width !=#{ASPECT_RATIO_DEFAULT_WIDTH} or native_height != #{ASPECT_RATIO_DEFAULT_HEIGHT}"

    MwInteractive.where(like_has_custom_sizes).update_all("aspect_ratio_method = 'MANUAL'")

    # 3. All codap documents that specify scaling=true use 'DEFAULT'
    like_in_codap = "url like '%http%document-store%&scaling%'"
    MwInteractive.where(like_in_codap).update_all("aspect_ratio_method = 'DEFAULT'")
  end

  def down
    remove_column :mw_interactives, :aspect_ratio_method
  end

end
