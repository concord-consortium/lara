class UpdateLogosAndSetProjectKeys < ActiveRecord::Migration
  class Project < ApplicationRecord
  end

  def up
    logo_url_root = "https://static.concord.org/projects/logos/lara/"
    Project.all.each do |p|
      if p.logo_lara.present? && !p.logo_lara.start_with?(logo_url_root)
        p.logo_lara = "#{logo_url_root}#{p.logo_lara}"
      end
      project_key = p.title.downcase.tr(" ", "-")
      p.project_key = project_key
      p.save
    end
  end

  def down
    logo_url_root = "https://static.concord.org/projects/logos/lara/"
    Project.all.each do |p|
      if p.logo_lara.present? && p.logo_lara.start_with?(logo_url_root)
        p.logo_lara = p.logo_lara.sub(logo_url_root, "")
      end
      p.project_key = nil
      p.save
    end
  end
end
