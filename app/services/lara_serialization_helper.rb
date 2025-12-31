class LaraSerializationHelper

  def initialize
    @entries = {}
  end

  def export(item)
    results = item.export
    results[:type] = item.class.name
    results[:ref_id] = key(item)
    if item.respond_to?(:interactive) && item.interactive
      results[:interactive_ref_id] = key(item.interactive)
    end
    if item.respond_to?(:embeddable) && item.embeddable
      results[:embeddable_ref_id] = key(item.embeddable)
    end
    # The linked interactive and data_source_interactive is fully serialized because when importing we may need
    # to create it because the embeddable it links to is not yet present.  The import method will take care of
    # avoiding duplicates by looking up existing items by ref_id.
    if item.respond_to?(:linked_interactive) && item.linked_interactive
      results[:linked_interactive] = self.export(item.linked_interactive)
    end
    if item.respond_to?(:data_source_interactive) && item.data_source_interactive
      results[:data_source_interactive] = self.export(item.data_source_interactive)
    end

    # This is done here and not in the models as we don't want to export the linked embeddables as they are already exported
    # we only want to save the key so that the references to the embeddables can be restored during import.
    # The embeddedable references are saved instead of the page_item references as new page_items are created when the
    # embeddables are imported into the page.
    if item.respond_to?(:primary_linked_items)
      results[:linked_interactives] = item.primary_linked_items.map {|pli| {
        ref_id: key(pli.secondary.embeddable),
        label: pli.label
      }}
    end
    results
  end

  def import(item_hash)
    existing_item = lookup_item(item_hash[:ref_id])
    return existing_item if existing_item

    item = item_hash[:type].constantize.import(item_hash.except(:type, :ref_id, :interactive_ref_id, :embeddable_ref_id, :linked_interactive, :linked_interactives, :data_source_interactive))
    item.save!(validate: false)
    unless item_hash[:ref_id]
      # This is only for backward compatibility when not all the embeddables were defining ref_id in export hash.
      item_hash[:ref_id] = key(item)
    end
    cache_item(item_hash[:ref_id], item)
    item
  end

  def set_references(item_hash)
    item = lookup_item(item_hash[:ref_id])
    if item_hash[:interactive_ref_id] && item.respond_to?(:interactive=)
      item.interactive = lookup_item(item_hash[:interactive_ref_id])
    end
    if item_hash[:embeddable_ref_id] && item.respond_to?(:embeddable=)
      item.embeddable = lookup_item(item_hash[:embeddable_ref_id])
    end
    if item_hash[:linked_interactive] && item.respond_to?(:linked_interactive)
      item.linked_interactive = import(item_hash[:linked_interactive])
    end
    if item_hash[:data_source_interactive] && item.respond_to?(:data_source_interactive)
      item.data_source_interactive = import(item_hash[:data_source_interactive])
    end
    if item_hash[:linked_interactives]
      item_hash[:linked_interactives].each do |lpi_hash|
        secondary = lookup_item(lpi_hash[:ref_id])
        if secondary
          lpi = LinkedPageItem.new(primary_id: item.page_item.id, secondary_id: secondary.page_item.id, label: lpi_hash[:label])
          lpi.save!(validate: false)
        end
      end
    end
    item.save!(validate: false)
    item
  end

  def key(item)
    "#{item.id}-#{item.class.name}"
  end

  private

  def cache_item(ref_id, item)
    @entries[ref_id] = item
  end

  def lookup_item(key_sting)
    @entries[key_sting]
  end
end
