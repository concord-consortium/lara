class Import < ActiveRecord::Base

  attr_accessible :export_site
  belongs_to :user
  belongs_to :import_item, polymorphic: true

  def self.import(upload,current_user,imported_activity_url=nil)
    begin
      json_object = JSON.parse "#{upload['import'].read}", :symbolize_names => true
      if(json_object[:type] == "LightweightActivity")
        @import_item = LightweightActivity.import(json_object,current_user,imported_activity_url)
      elsif (json_object[:type] == "Sequence")
        @import_item = Sequence.import(json_object,current_user,imported_activity_url)
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
      logger.error e.message
      logger.error e.backtrace.join("\n")
      return nil
    end

    @import_item

  end
end
