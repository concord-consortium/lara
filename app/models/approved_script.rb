class ApprovedScript < ApplicationRecord
  # attr_accessible :name, :url, :label, :description, :version, :json_url, :authoring_metadata
  validates :name, presence: true
  validates :label, format: {
    with: /\A([A-Za-z0-9]+)\z/,
    message: "only use letters and numbers."
  }
  validates :url, format: {
    with: /\Ahttps?:\/\//i,
    message: "include protocol (https://)"
  }
  belongs_to :appoved_script

  def self.authoring_menu_items(scope, embeddable=nil)
    embeddable_class = embeddable ? embeddable.class.name : nil
    menu_items = []
    ApprovedScript.all.each do |as|
      as.components_for_authoring_scope(scope).each do |c|
        if !embeddable_class || (c.has_key?(:decorates) && c[:decorates].include?(embeddable_class))
          menu_items.push(OpenStruct.new({
            approved_script_id: as[:id],
            component_label: c[:label],
            component_name: c[:name],
            name: "#{as[:name]}: #{c[:name]}"
          }))
        end
      end
    end
    menu_items
  end

  def self.available_plugins_for_embeddable(embeddable)
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

  def to_hash
    {
      name: name,
      url: url,
      label: label,
      description: description,
      version: version,
      json_url: json_url,
      authoring_metadata: authoring_metadata
    }
  end

  def option_value
    "#{self.json_url} (##{self.id})"
  end
end
