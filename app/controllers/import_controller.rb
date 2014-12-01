class ImportController < ApplicationController

  def import_status
    @message = params[:message] || ''
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('import')}, :content_type => 'text/json' }
      format.html
    end
  end
  
  def import
    @import_item = Import.import(params[:import],current_user)
    class_name = @import_item.nil? ? '' : @import_item.class.name
    if(class_name == 'LightweightActivity')
      unless @import_item.valid?
        flash[:warning] =  "<p>The import activity had validation issues:</p> #{@import_item.errors}"
      end
      if @import_item.save(:validations => false) # In case the old activity was invalid
        respond_to do |format|
          format.js { render :js => "window.location.href = 'activities/#{@import_item.id}/edit';" }
        end
      else
        respond_to do |format|
          format.js { render :json => { :error =>"Import failed."}, :status => 500 }
        end
      end
    elsif(class_name == 'Sequence')
      unless @import_item.valid?
        flash[:warning] =  "<p>The import sequence had validation issues:</p> #{@import_item.errors}"
      end
      if @import_item.save(:validations => false) # In case the old activity was invalid
        respond_to do |format|
          format.js { render :js => "window.location.href = 'sequences/#{@import_item.id}/edit';" }
        end
      else
        respond_to do |format|
          format.js { render :json => { :error =>"Import failed."}, :status => 500 }
        end
      end
    else
      respond_to do |format|
        format.js { render :json => { :error =>"Import failed because of invalid JSON file."}, :status => 500 }
      end
    end
  end
end
  
