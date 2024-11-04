# to be run in rails console to add component labels to version 3 plugins

ApprovedScript.where({version: 3}).each do |as|
  if as.url =~ /teacher-edition-tips-plugin/
    Plugin.where({approved_script_id: as.id}).each do |p|
      begin
        author_data = JSON.parse(p.author_data, symbolize_names: true)
        if author_data && author_data[:tipType] && p.component_label.blank?
          # the component label is the same as the tip type in the teacher tips manifest
          p.component_label = author_data[:tipType]
          p.save!
        end
      rescue
        nil
      end
    end
  elsif (as.url =~ /lara-sharing-plugin/) || (as.url =~ /glossary-plugin/) || (as.url =~ /model-feedback/)
    metadata = JSON.parse(as.authoring_metadata, symbolize_names: true)
    # lara sharing, glossary and model-feedback only have 1 component
    component_label = metadata[:components][0][:label]
    Plugin.where({approved_script_id: as.id}).each do |p|
      if p.component_label.blank?
        p.component_label = component_label
        p.save!
      end
    end
  end
end
