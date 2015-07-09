class LaraSerializationHelper

  def initialize
    @entries = {}
  end

  def cache_item(ref_id, item)
    @entries[ref_id] = item
  end

  def cache_item_copy(original_item, copy_of_item)
    cache_item(key(original_item), copy_of_item)
  end

  def lookup_item(key_sting)
    @entries[key_sting]
  end

  def lookup_new_item(original_item)
    lookup_item(key(original_item))
  end

  def key(item)
    "#{item.id}-#{item.class.name}"
  end

  def wrap_export(item)
    results = item.export
    results[:type] = item.class.name
    case item
    when MwInteractive, ImageInteractive, VideoInteractive
      results[:ref_id] = key(item)
    when Embeddable::Labbook
      results[:interactive_ref_id] = key(item.interactive)
    end
    results
  end

  def wrap_import(item_hash)
    item = item_hash[:type].constantize.import(item_hash.except(:type,:ref_id,:interactive_ref_id))
    if item_hash[:interactive_ref_id]
      if item.respond_to? :interactive=
        item.interactive=lookup_item(item_hash[:interactive_ref_id])
      end
    end
    item.save!(validate: false)
    if item_hash[:ref_id]
      cache_item(item_hash[:ref_id], item)
    end
    item
  end

end
