class ChangeIsFullWidthToIsHalfWidth < ActiveRecord::Migration
  class Embeddable::ImageQuestion < ApplicationRecord
  end
  class Embeddable::Labbook < ApplicationRecord
  end
  class Embeddable::MultipleChoice < ApplicationRecord
  end
  class Embeddable::OpenResponse < ApplicationRecord
  end
  class Embeddable::EmbeddablePlugin < ApplicationRecord
  end
  class Embeddable::Xhtml < ApplicationRecord
  end
  class ImageInteractive < ApplicationRecord
  end
  class ManagedInteractive < ApplicationRecord
  end
  class MwInteractive < ApplicationRecord
  end
  class VideoInteractive < ApplicationRecord
  end

  def up
    rename_column :embeddable_image_questions, :is_full_width, :is_half_width
    change_column :embeddable_image_questions, :is_half_width, :boolean, :default => true
    execute "UPDATE embeddable_image_questions SET is_half_width = NOT is_half_width"
    rename_column :embeddable_labbooks, :is_full_width, :is_half_width
    change_column :embeddable_labbooks, :is_half_width, :boolean, :default => true
    execute "UPDATE embeddable_labbooks SET is_half_width = NOT is_half_width"
    rename_column :embeddable_multiple_choices, :is_full_width, :is_half_width
    change_column :embeddable_multiple_choices, :is_half_width, :boolean, :default => true
    execute "UPDATE embeddable_multiple_choices SET is_half_width = NOT is_half_width"
    rename_column :embeddable_open_responses, :is_full_width, :is_half_width
    change_column :embeddable_open_responses, :is_half_width, :boolean, :default => true
    execute "UPDATE embeddable_open_responses SET is_half_width = NOT is_half_width"
    rename_column :embeddable_plugins, :is_full_width, :is_half_width
    change_column :embeddable_plugins, :is_half_width, :boolean, :default => true
    execute "UPDATE embeddable_plugins SET is_half_width = NOT is_half_width"
    rename_column :embeddable_xhtmls, :is_full_width, :is_half_width
    change_column :embeddable_xhtmls, :is_half_width, :boolean, :default => true
    execute "UPDATE embeddable_xhtmls SET is_half_width = NOT is_half_width"
    rename_column :image_interactives, :is_full_width, :is_half_width
    change_column :image_interactives, :is_half_width, :boolean, :default => false
    execute "UPDATE image_interactives SET is_half_width = NOT is_half_width"
    rename_column :managed_interactives, :is_full_width, :is_half_width
    change_column :managed_interactives, :is_half_width, :boolean, :default => false
    execute "UPDATE managed_interactives SET is_half_width = NOT is_half_width"
    rename_column :mw_interactives, :is_full_width, :is_half_width
    change_column :mw_interactives, :is_half_width, :boolean, :default => false
    execute "UPDATE mw_interactives SET is_half_width = NOT is_half_width"
    rename_column :video_interactives, :is_full_width, :is_half_width
    change_column :video_interactives, :is_half_width, :boolean, :default => false
    execute "UPDATE video_interactives SET is_half_width = NOT is_half_width"
  end

  def down
    rename_column :embeddable_image_questions, :is_half_width, :is_full_width
    change_column :embeddable_image_questions, :is_full_width, :boolean, :default => false
    execute "UPDATE embeddable_image_questions SET is_full_width = NOT is_full_width"
    rename_column :embeddable_labbooks, :is_half_width, :is_full_width
    change_column :embeddable_labbooks, :is_full_width, :boolean, :default => false
    execute "UPDATE embeddable_labbooks SET is_full_width = NOT is_full_width"
    rename_column :embeddable_multiple_choices, :is_half_width, :is_full_width
    change_column :embeddable_multiple_choices, :is_full_width, :boolean, :default => false
    execute "UPDATE embeddable_multiple_choices SET is_full_width = NOT is_full_width"
    rename_column :embeddable_open_responses, :is_half_width, :is_full_width
    change_column :embeddable_open_responses, :is_full_width, :boolean, :default => false
    execute "UPDATE embeddable_open_responses SET is_full_width = NOT is_full_width"
    rename_column :embeddable_plugins, :is_half_width, :is_full_width
    change_column :embeddable_plugins, :is_full_width, :boolean, :default => false
    execute "UPDATE embeddable_plugins SET is_full_width = NOT is_full_width"
    rename_column :embeddable_xhtmls, :is_half_width, :is_full_width
    change_column :embeddable_xhtmls, :is_full_width, :boolean, :default => false
    execute "UPDATE embeddable_xhtmls SET is_full_width = NOT is_full_width"
    rename_column :image_interactives, :is_half_width, :is_full_width
    change_column :image_interactives, :is_full_width, :boolean, :default => true
    execute "UPDATE image_interactives SET is_full_width = NOT is_full_width"
    rename_column :managed_interactives, :is_half_width, :is_full_width
    change_column :managed_interactives, :is_full_width, :boolean, :default => true
    execute "UPDATE managed_interactives SET is_full_width = NOT is_full_width"
    rename_column :mw_interactives, :is_half_width, :is_full_width
    change_column :mw_interactives, :is_full_width, :boolean, :default => true
    execute "UPDATE mw_interactives SET is_full_width = NOT is_full_width"
    rename_column :video_interactives, :is_half_width, :is_full_width
    change_column :video_interactives, :is_full_width, :boolean, :default => true
    execute "UPDATE video_interactives SET is_full_width = NOT is_full_width"
  end
end
