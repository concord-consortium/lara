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
    
    unless @import_activity.nil? 
      unless @import_activity.valid?
        flash[:warning] =  "<p>The import activity had validation issues:</p> #{@new_activity.errors}"
      end
  
      if @import_activity.save(:validations => false) # In case the old activity was invalid
        redirect_to edit_activity_path(@import_activity)
      else
        flash[:warning] =  "Import failed"
        redirect_to activities_path
      end
    else
      flash[:warning] =  "Import failed because of invalid JSON file."
      redirect_to activities_path
    end
  end

end
