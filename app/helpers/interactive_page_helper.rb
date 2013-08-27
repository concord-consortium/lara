module InteractivePageHelper
  def runnable_activity_page_path(activity, page)
    if @run
      page_with_response_path(activity.id, page.id, @run.key)
    else
      activity_page_path(activity, page)
    end
  end
end
