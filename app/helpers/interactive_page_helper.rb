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
end
