# Common code for the controllers for the different kinds of Interactive models
class InteractiveController < ApplicationController
  def edit
    respond_with_edit_form("allow-full-width")
  end

  def update
    set_page
    input_params = get_interactive_params
    # linked_interactives param follows ISetLinkedInteractives interface format. It isn't a regular attribute.
    # It requires special treatment and should be removed from params before .update_attributes is called.
    if input_params.has_key? :linked_interactives
      linked_linteractives = input_params.delete :linked_interactives
      if linked_linteractives.present?
        set_linked_interactives(JSON.parse linked_linteractives)
      end
    end
    @interactive.update_attributes! input_params
    respond_to do |format|
      update_activity_changed_by(@activity)
      format.html { redirect_to edit_activity_page_path(@activity, @page) }
      format.json { render :json => @interactive.to_json }
    end
  end

  protected
  def set_page
    if @interactive
      @page = @interactive.page
      @activity = @interactive.activity
    end
  end

  def set_linked_interactives(options)
    source_page_item = @interactive.page_item
    if !source_page_item
      raise "Interactive needs to be added to a page"
    end
    source_page_item_id = source_page_item.id

    ActiveRecord::Base.transaction do
      if options.has_key?("linkedInteractives")
        linked_interactives = options["linkedInteractives"]
        # clear the existing links
        LinkedPageItem.delete_all(primary_id: source_page_item_id)

        # convert {0: {id:...}, 1: {id: ...}} to [{id:...}, {id:...}]
        if linked_interactives.is_a? Hash
          linked_interactives = linked_interactives.values
        end

        # add the new links
        linked_interactives.each do |item|
          if !item.is_a? Hash
            raise "Invalid linkedInteractives parameter, each array item needs to be a hash"
          end
          if item["id"].nil? || item["label"].nil?
            raise "Missing id or label value in linkedInteractives item"
          end
          secondary_id = extract_page_item_id(item["id"])
          if secondary_id.nil?
            raise "Invalid interactive id: #{item["id"]}"
          end
          item = LinkedPageItem.new({primary_id: source_page_item_id, secondary_id: secondary_id, label: item["label"]})
          if !item.save
            raise "Unable to create linkedInteractive for #{item["id"]}"
          end
        end
      end

      if options.has_key?("linkedState")
        linked_state_page_item_id = options["linkedState"].nil? ? nil : extract_page_item_id(options["linkedState"])
        if linked_state_page_item_id
          linked_state_page_item = @page.page_items.find { |i| i.id == linked_state_page_item_id.to_i }
          if !linked_state_page_item
            raise "Invalid linkedState parameter in request"
          end
          source_page_item.embeddable.linked_interactive = linked_state_page_item.embeddable
          if !source_page_item.embeddable.save
            raise "Unable to set linkedState to #{linked_state_page_item_id}"
          end
        else
          source_page_item.embeddable.linked_interactive = nil
          if !source_page_item.embeddable.save
            raise "Unable to remove linkedState"
          end
        end
      end
    end
  end

  def extract_page_item_id(interative_id)
    m = interative_id.match(/^interactive_(.+)$/)
    m ? m[1] : nil
  end
end
