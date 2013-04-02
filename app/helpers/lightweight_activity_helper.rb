module LightweightActivityHelper
  def toggle_all(label='all', id_prefix='details_')
    link_to_function("show/hide #{label}", "$('div[id^=#{id_prefix}]').toggle();")
  end

  def has_good_content(value)
    return false if value.nil?
    related = value.gsub(/(<([^>]+)>)/,'')
    return (!related.blank?)
  end
end
