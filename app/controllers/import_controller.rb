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
    res_name = @import_item.nil? ? '' : @import_item.class.name == 'LightweightActivity' ? 'activities' : 'sequences'  
    respond_to do |format|
      unless(res_name == '')
        unless @import_item.valid?
          flash[:warning] =  "<p>The import activity had validation issues:</p> #{@import_item.errors}"
        end
        if @import_item.save(:validations => false)
          format.js { render :js => "window.location.href = '#{res_name}/#{@import_item.id}/edit';" }
        else
          format.js { render :json => { :error =>"Import failed."}, :status => 500 }
        end
      else
        format.js { render :json => { :error =>"Import failed because of invalid JSON file."}, :status => 500 }
      end
    end
  end
end
  
