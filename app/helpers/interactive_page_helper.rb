module InteractivePageHelper
  def runnable_activity_page_path(activity, page)
    if @run
      page_with_response_path(activity.id, page.id, @run.key)
    elsif activity and page
      activity_page_path(activity, page)
    elsif activity
      activity_path(activity)
    else
      nil
    end
  end
  def page_link(activity,page)
    name = "Page #{page.position}"
    name = page.name unless page.name.blank?
    return link_to name, runnable_activity_page_path(activity,page)
  end
end
