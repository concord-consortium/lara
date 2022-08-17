class Api::V1::PageItemsController < API::APIController
  layout false
  before_filter :set_page_item

  def export_page_item_embeddable
    results = (LaraSerializationHelper.new).export(@page_item.embeddable).to_json
    render :json => results
  end

  def get_embeddable_metadata
    render :json => {
      success: true,
      embeddable_id: @page_item.embeddable_id,
      embeddable_type: @page_item.embeddable_type
    }
  end

  def get_page_item_plugins
    plugins = []
    page_item_plugins = Embeddable::EmbeddablePlugin.where({embeddable_id: @page_item.embeddable_id, embeddable_type: @page_item.embeddable_type})
    page_item_plugins.each do |plugin|
      plugin_page_item = plugin.page_items.first
      plugins.push({
        :embeddable_id => @page_item.embeddable_id,
        :id => plugin.id,
        :name => plugin.name,
        :section_item_id => plugin_page_item.id
      })
    end

    render :json => {
      plugins: plugins
    }
  end

  private

  def set_page_item
    begin
      @page_item = PageItem.find(params['id'])
    rescue ActiveRecord::RecordNotFound
      render :json => { :success => false, :message => "Could not find page item ##{params['id']}"}
    end
  end
end
