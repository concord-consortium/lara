class Import < ActiveRecord::Base
  def self.import(upload,current_user)
    
    json_object = JSON.parse "#{upload['import'].read}"
    
    @import_activity = LightweightActivity.import(json_object,current_user)
    
    @import_activity
        
  end
end
