
class Plugin < ActiveRecord::Base

  attr_accessible :description, :author_data, :approved_script_id, :approved_script

  belongs_to :approved_script
  belongs_to :plugin_scope, polymorphic: true

  delegate :name,  to: :approved_script, allow_nil: true
  delegate :label, to: :approved_script, allow_nil: true
  delegate :url,   to: :approved_script, allow_nil: true
  delegate :version, to: :approved_script, allow_nil: true

  # TODO: Import / export / to_hash &etc for duplicating ...
  #
  # def self.import(import_hash)
  #   return self.new(import_hash)
  # end

  # def to_hash
  #   {
  #     approved_script_id: approved_script_id,
  #     author_data: author_data,
  #     description: description
  #   }
  # end

  # def portal_hash
  #   {
  #     type: "lara_plugin",
  #     id: id,
  #     url: url,
  #     author_data: author_data,
  #     name: name
  #   }
  # end

  # def duplicate
  #   return Plugin.new(self.to_hash)
  # end

  # def export
  #   return self.as_json(only:[:name, :url, :author_data, :description])
  # end

end
