module CollectionFilterHelper

  def collection_filter_tag(filter=nil)
    return if current_user.nil?
    return if filter.nil?
    render partial: "shared/collection_filter", locals: {filter: filter}
  end
end
