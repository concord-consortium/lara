class Api::V1::InteractivePagesController < ApplicationController
  layout false
  before_filter :set_interactive_page

  def get_interactive_list
    begin
      authorize! :read, @interactive_page

      scope = params[:scope] || "page"
      supports_snapshots = params[:supportsSnapshots]

      if scope != "page"
        raise "Invalid scope parameter: #{scope}"
      end

      interactives = @interactive_page
        .interactive_page_items
        .select do |pi|
          i = pi.embeddable
          case supports_snapshots
          when "true"
            !i.no_snapshots
          when "false"
            i.no_snapshots
          else
            # supportsSnapshots is optional
            true
          end
        end
        .map do |pi|
          i = pi.embeddable
          {
            id: "interactive_#{pi.id}",
            pageId: @interactive_page.id,
            name: i.name,
            section: pi.section != nil ? pi.section : "assessment_block",
            url: i.url,
            thumbnailUrl: i.thumbnail_url,
            supportsSnapshots: !i.no_snapshots
          }
        end

      render :json => { :success => true, interactives: interactives}

    rescue CanCan::AccessDenied
      return render :json => { :success => false, :message => "You are not authorized to get the interactive list from the requested page"}
    rescue => error
      return render :json => { :success => false, :message => error.message}
    end
  end

  def set_linked_interactives
    begin
      begin
        authorize! :create, LinkedPageItem
      rescue CanCan::AccessDenied
        raise "You are not authorized to create linked interactives"
      end

      source_id = params[:sourceId]
      if !source_id
        raise "Missing sourceId parameter in request"
      end
      source_page_item_id = extract_page_item_id(source_id)
      if !source_page_item_id
        raise "Invalid sourceId parameter in request: #{source_id}"
      end

      source_page_item = @interactive_page.page_items.find_by_id(source_page_item_id)
      if !source_page_item
        raise "Unknown sourceId parameter in request: #{source_page_item_id}"
      end

      begin
        authorize! :manage, source_page_item
      rescue CanCan::AccessDenied
        raise "You are not authorized to set linked interactives for the requested page"
      end

      if !params.has_key?(:linkedInteractives) && !params.has_key?(:linkedState)
        raise "Missing linkedInteractives or linkedState parameters in request"
      end
      linked_interactives = params[:linkedInteractives]
      linked_state = params[:linkedState]

      if linked_state
        linked_state_page_item_id = extract_page_item_id(linked_state)
        if !linked_state_page_item_id
          raise "Invalid linkedState parameter in request: #{linked_state}"
        end
      end

      ActiveRecord::Base.transaction do
        if linked_interactives
          # clear the existing links
          LinkedPageItem.delete_all(primary_id: source_page_item_id)

          # convert {0: {id:...}, 1: {id: ...}} to [{id:...}, {id:...}]
          if linked_interactives.is_a? Hash
            linked_interactives = linked_interactives.values
          end

          # Check if linked_interactives is an array, as client can send linked_interactives equal to null or empty
          # string. These requests should be treated as a way to clear linked interactives list.
          if linked_interactives.is_a? Array
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
        end

        if linked_state_page_item_id
          linked_state_page_item = @interactive_page.page_items.find_by_id(linked_state_page_item_id)
          if !linked_state_page_item
            raise "Invalid linkedState parameter in request"
          end

          source_page_item.embeddable.linked_interactive = linked_state_page_item.embeddable
          if !source_page_item.embeddable.save
            raise "Unable to set linkedState to #{linked_state_page_item_id}"
          end
        end
      end

      render :json => { :success => true}

    rescue => error
      return render :json => { :success => false, :message => error.message}
    end
  end

  private

  def set_interactive_page
    begin
      @interactive_page = InteractivePage.find(params['id'])
    rescue ActiveRecord::RecordNotFound
      render :json => { :success => false, :message => "Could not find interactive page ##{params['id']}"}
    end
  end

  def extract_page_item_id(interative_id)
    m = interative_id.match(/^interactive_(.+)$/)
    m ? m[1] : nil
  end
end
