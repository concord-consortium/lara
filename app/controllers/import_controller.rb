class ImportController < ApplicationController

  def import_status
    @message = params[:message] || ''
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('import')}, :content_type => 'text/json' }
      format.html
    end
  end
  
  def import
    @import_activity = Import.import(params[:import],current_user)
    
    message = ''
    
    unless @import_activity.valid?
      message << "<p>The import activity had validation issues:</p> #{@new_activity.errors}"
    end

    if @import_activity.save(:validations => false) # In case the old activity was invalid
      redirect_to edit_activity_path(@import_activity)
    else
      message << "Copy failed"
      redirect_to activities_path
    end
    
    #render :nothing => true
  end

end
