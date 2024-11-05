class CreateProjects < ActiveRecord::Migration[5.1]
  class Theme < ApplicationRecord
  end

  class Project < ActiveRecord::Base
    attr_accessible :logo, :title, :url
  end

  def up
    create_table :projects do |t|
      t.string :title
      t.string :logo
      t.string :url
      t.text :footer

      t.timestamps
    end

    mw = CreateProjects::Project.new(:title => 'Molecular Workbench', :logo => 'mw-logo.png', :url => 'http://mw.concord.org/nextgen')
    mw_theme = Theme.find_by_name('NextGen MW')
    mw.footer = mw_theme.footer
    mw.save
    has = CreateProjects::Project.new(:title => 'High Adventure Science', :url => 'http://has.concord.org')
    has.save
    remove_column :themes, :footer

    add_column :lightweight_activities, :project_id, :integer
    add_column :sequences, :project_id, :integer
  end

  def down
    drop_table :projects
    add_column :themes, :footer, :text
    remove_column :lightweight_activities, :project_id
    remove_column :sequences, :project_id
  end
end
