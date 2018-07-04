class AddInteractiveToImageQuestion < ActiveRecord::Migration
  def up
    add_column :embeddable_image_questions, :interactive_id, :integer
    add_column :embeddable_image_questions, :interactive_type, :string

    Embeddable::ImageQuestion.find_each(batch_size: 10) do |iq|
      # Previously, image question was always referring the first interactive on the page.
      # Follow this logic to pick the right interactive and set it explicitly using new columns.
      page = iq.interactive_pages.first
      interactive = page && page.visible_interactives.first
      if interactive
        # update_column shouldn't trigger any callbacks. Safer than iq.interactive = interactive.
        iq.update_column('interactive_id', interactive.id)
        iq.update_column('interactive_type', interactive.class.to_s)
      end
    end
  end

  def down
    remove_column :embeddable_image_questions, :interactive_id
    remove_column :embeddable_image_questions, :interactive_type
  end
end
