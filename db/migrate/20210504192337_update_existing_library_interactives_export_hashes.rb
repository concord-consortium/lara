class UpdateExistingLibraryInteractivesExportHashes < ActiveRecord::Migration[5.1]

  class LibraryInteractive < ActiveRecord::Base
  end

  def export(li)
    li.as_json(only:[
      :aspect_ratio_method,
      :base_url,
      :click_to_play,
      :click_to_play_prompt,
      :enable_learner_state,
      :full_window,
      :has_report_url,
      :image_url,
      :native_height,
      :native_width,
      :no_snapshots,
      :show_delete_data_button,
      :thumbnail_url,
      :customizable,
      :authorable
    ])
  end

  def old_export(li)
    li.as_json(only:[
      :aspect_ratio_method,
      :authoring_guidance,
      :base_url,
      :click_to_play,
      :click_to_play_prompt,
      :description,
      :enable_learner_state,
      :full_window,
      :has_report_url,
      :image_url,
      :name,
      :native_height,
      :native_width,
      :no_snapshots,
      :show_delete_data_button,
      :thumbnail_url,
      :customizable,
      :authorable
    ])
  end

  def up
    LibraryInteractive.find_each(batch_size: 100) do |li|
      new_export_hash = Digest::SHA1.hexdigest(export(li).to_json)
      li.update_column('export_hash', new_export_hash)
    end
  end

  def down
    LibraryInteractive.find_each(batch_size: 100) do |li|
      old_export_hash = Digest::SHA1.hexdigest(old_export(li).to_json)
      li.update_column('export_hash', old_export_hash)
    end
  end
end
