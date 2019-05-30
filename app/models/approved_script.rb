class ApprovedScript < ActiveRecord::Base
  attr_accessible :name, :url, :label, :description, :version, :json_url, :authoring_metadata
  validates :name, presence: true
  validates :label, format: {
    with: /^([A-Za-z0-9]+)$/,
    message: "only use letters and numbers."
  }
  validates :url, format: {
    with: /^https?:\/\//i,
    message: "include protocol (https://)"
  }
  belongs_to :appoved_script

  def self.authoring_menu_items(scope)
    menu_items = []
    ApprovedScript.all.each do |as|
      as.components_for_authoring_scope(scope).each do |c|
        menu_items.push(OpenStruct.new({
          approved_script_id: as[:id],
          component_label: c[:label],
          component_name: c[:name]
        }))
      end
    end
    menu_items
  end

  def components
    parsed_authoring_metadata[:components] || []
  end

  def component(label)
    c = components.find {|c| c[:label] == label}
    c && OpenStruct.new(c)
  end

  def components_for_authoring_scope(scope)
    components.select {|c| c[:scope] == scope}
  end

  def parsed_authoring_metadata
    begin
      JSON.parse authoring_metadata, :symbolize_names => true
    rescue
      {}
    end
  end
end
