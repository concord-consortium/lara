# encoding: UTF-8
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

  def button_tag(value,extra)
    attributes = extra.merge({
      "class" => "button",
      "type" => "button",
      "value" => value})
    capture_haml do
      haml_tag :input, attributes
    end
  end

  def default_footer
    <<-EOF
      <p class="footer-txt">
        Copyright © 2013 <a href="http://concord.org/">The Concord Consortium</a>. 
        All rights reserved. This activity is licensed under a 
        <a href="http://creativecommons.org/licenses/by/3.0/">
          Creative Commons Attribution 3.0 Unported License
        </a>. 
        The software is licensed under 
        <a href="http://opensource.org/licenses/BSD-2-Clause">
          Simplified BSD
        </a>, <a href="http://opensource.org/licenses/MIT">MIT</a>
        or <a href="http://opensource.org/licenses/Apache-2.0">Apache 2.0</a> 
        licenses. Please provide attribution to the Concord Consortium and 
        the URL <a href="http://concord.org">http://concord.org</a>.
     </p>
      <p class="footer-txt">
        This Next-Generation Molecular Workbench activity was developed with a grant from 
        <a href="http://www.google.org/">Google.org</a>. 
        The original <a href="http://mw.concord.org/modeler/">Classic Molecular Workbench</a> 
        was supported by a series of grants from the 
        <a href="http://nsf.gov/">National Science Foundation</a>.
      </p>
    EOF
  end

  def project_footer
    return if @page # don't display footers when running on a page.
    return default_footer unless @project
    return default_footer if @project.footer.blank?
    return @project.footer
  end

end
