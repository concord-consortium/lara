class Import < ActiveRecord::Base
  
  attr_accessible :export_site
  belongs_to :user
  belongs_to :import_item, polymorphic: true 
  
  def self.import(upload,current_user)
    begin
      json_object = JSON.parse "#{upload['import'].read}", :symbolize_names => true
      if(json_object[:type] == "LightweightActivity")
        @import_item = LightweightActivity.import(json_object,current_user)
      elsif (json_object[:type] == "Sequence")
        @import_item = Sequence.import(json_object,current_user)
      else
        return nil
      end
      
      @import = Import.new({export_site:json_object[:export_site]});
      
      Import.transaction do
        @import.user = current_user
        @import.import_item = @import_item
        @import.save!(validate: false)
      end
      
    rescue => e
       return nil
    end
    
    @import_item
    
  end
end
