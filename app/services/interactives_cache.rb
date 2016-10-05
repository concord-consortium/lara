class InteractivesCache

  def initialize
    @entries = {}
  end

  def set(ref_id, item)
    @entries[ref_id] = item
  end

  def get(ref_id)
    @entries[ref_id]
  end

end
