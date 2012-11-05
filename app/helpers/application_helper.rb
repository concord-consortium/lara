module Lightweight
  module ApplicationHelper
    def edit_menu_for(component, form, options={:omit_cancel => true}, scope=false)
      component = (component.respond_to? :embeddable) ? component.embeddable : component
      capture_haml do
        haml_tag :div, :class => 'action_menu' do
          haml_tag :div, :class => 'action_menu_header_left' do
            haml_tag(:h3,{:class => 'menu'}) do
              haml_concat title_for_component(component, :id_prefix => 'edit')
            end
          end
          haml_tag :div, :class => 'action_menu_header_right' do
            haml_tag :ul, {:class => 'menu'} do
              #if (component.changeable?(current_user))
              haml_tag(:li, {:class => 'menu'}) { haml_concat form.submit("Save") }
              haml_tag(:li, {:class => 'menu'}) { haml_concat form.submit("Cancel") } unless options[:omit_cancel]
              #end
            end
          end
        end
      end
    end

    def title_for_component(component, options={})
      title = name_for_component(component, options)
      id = dom_id_for(component, options[:id_prefix], :title)
#      if ::Rails.env == "development" || @current_user.has_role?('admin')
      if false # TODO: Get this working correctly
        "<span id=#{id} class='component_title'>#{title}</span><span class='dev_note'> #{link_to(component.id, component)}</span>"
      else
        "<span id=#{id} class='component_title'>#{title}</span>"
      end
    end

    def name_for_component(component, options={})
      if options[:display_name]
        return options[:display_name]
      end
      name = ''
      unless options[:hide_component_name]
        if component.class.respond_to? :display_name
          name << component.class.display_name
        else
          name << component.class.name.humanize
        end
        if component.respond_to? :display_type
          name = "#{component.display_type} #{name}"
        end
        name << ': '
      end
      default_name = ''
      if component.class.respond_to?(:default_value)
        default_name = component.class.default_value('name')
      end
      name << case
        when component.id.nil? then "(new)"
        when component.name == default_name then ''
        when component.name then component.name
        else ''
      end
    end

    def dom_id_for(component, *optional_prefixes)
      optional_prefixes.flatten!
      optional_prefixes.compact! unless optional_prefixes.empty?
      prefix = ''
      optional_prefixes.each { |p| prefix << "#{p.to_s}_" }
      class_name = component.class.name.underscore
      if component.is_a?(ActiveRecord::Base)
        id = component.id || Time.now.to_i
      else
        # this will be a temporary id, so it seems unlikely that these type of ids
        # should be really be generated, however there are some parts of the code
        # calling dom_id_for and passing a form object for example
        id = component.object_id
      end
      id_string = id.to_s
      "#{prefix}#{class_name}_#{id_string}"
    end
  end
end
