class Import < ActiveRecord::Base

  attr_accessible :export_site
  belongs_to :user
  belongs_to :import_item, polymorphic: true

  def self.import(json_object, user, imported_activity_url = nil)
    begin
      if json_object.instance_of?(String)
        json_object = JSON.parse json_object, :symbolize_names => true
      end
      if json_object[:type] == "LightweightActivity"
        @import_item = LightweightActivity.import(json_object, user, imported_activity_url)
      elsif json_object[:type] == "Sequence"
        @import_item = Sequence.import(json_object, user, imported_activity_url)
      else
        return {success: false, error: "Import failed: unknown type"}
      end

      @import = Import.new
      Import.transaction do
        @import.user = user
        @import.import_item = @import_item
        @import.export_site = json_object[:export_site]
        @import.save!(validate: false)
      end

      unless @import_item.valid?
        return {success: false, error: "Import failed, validation issues: #{@import_item.errors}"}
      end
      if @import_item.save(:validations => false)
        return {success: true, import_item: @import_item, type: json_object[:type]}
      else
        return {success: false, error: "Import failed: can't save activity"}
      end

    rescue => e
      logger.error e.message
      logger.error e.backtrace.join("\n")
      return {success: false, error: "Import failed: #{e.message.truncate(200)}"}
    end
  end
end
