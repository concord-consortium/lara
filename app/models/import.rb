class Import < ActiveRecord::Base
  def self.import(upload,current_user)
    
    begin
      json_object = JSON.parse "#{upload['import'].read}" 
      @import_activity = LightweightActivity.import(json_object,current_user)
    rescue => e
      return nil
    end
    
    @import_activity
    
  end
end
