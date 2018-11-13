# Helper that keeps references to various items (embeddables) across multiple pages or even activities.
class LaraDuplicationHelper

  def initialize
    @entries = {}
  end

  def get_copy(original_item)
    copy = lookup_item(key(original_item))
    unless copy
      copy = original_item.duplicate
      cache_item_copy(original_item, copy)
    end
    copy
  end

  private

  def cache_item_copy(original_item, copy_of_item)
    cache_item(key(original_item), copy_of_item)
  end

  def cache_item(ref_id, item)
    @entries[ref_id] = item
  end

  def lookup_item(key_sting)
    @entries[key_sting]
  end

  def key(item)
    "#{item.id}-#{item.class.name}"
  end
end
