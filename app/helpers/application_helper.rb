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
    if component.is_a?(ApplicationRecord)
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
        Copyright © #{Date.today.year} <a href="https://concord.org/" title="The Concord Consortium">The Concord Consortium</a>.
        All rights reserved. This material is licensed under a
        <a href="https://creativecommons.org/licenses/by/4.0/">
          Creative Commons Attribution 4.0 License
        </a>.
        The software is licensed under
        <a href="http://opensource.org/licenses/BSD-2-Clause">
          Simplified BSD
        </a>, <a href="http://opensource.org/licenses/MIT">MIT</a>
        or <a href="http://opensource.org/licenses/Apache-2.0">Apache 2.0</a>
        licenses. Please provide attribution to the Concord Consortium and
        the URL <a href="http://concord.org">http://concord.org</a>.
     </p>
    EOF
  end

  def project_footer
    return if @page # don't display footers when running on a page.
    return default_footer unless @project
    return default_footer if @project.footer.blank?
    return @project.footer
  end

  def time_to_complete(min)
    results = <<-EOF
      <span class='time_to_complete'>
        #{t("TIME_TO_COMPLETE")}
        <span class='time_estimate'>
          <span class='minutes_to_complete'>#{min}</span>
          <span class='minutes_text'>#{t("MINUTES")}</span>
        </span>
      </span>
    EOF
    results.html_safe
  end

  # Inserts TinyMCE text editor that edits given property (text property).
  # If :editable_header and :header_prop options are provided, the header will be editable too.
  # Otherwise, :header option can be used to use constant header / title
  def text_editor (object, property, options={})
    update_url = options.delete(:update_url) || url_for(object)
    id = "text-editor-#{property}-#{object.class.to_s.underscore}-#{object.id}"
    text_prop_name = "#{object.class.to_s.underscore}[#{property}]"
    text_value = object.send(property)
    header_prop_name = options[:header_prop] ? "#{object.class.to_s.underscore}[#{options[:header_prop]}]" : "non-editable-header"
    header_value =  options[:header_prop] ? object.send(options[:header_prop]) : nil
    %{
      <div id="#{id}"></div>
      <script type="text/javascript">
        (function() {
          var props = {
            data: {
              "#{text_prop_name}": #{text_value.to_json},
              "#{header_prop_name}": #{(header_value ? header_value : options[:header]).to_json},
            },
            updateUrl: "#{update_url}",
            textPropName: "#{text_prop_name}",
            headerPropName: "#{header_prop_name}",
            editableHeader: #{options[:editable_header] || false}
          };
          TextEditor = React.createElement(modulejs.require('components/authoring/text_editor'), props);
          ReactDOM.render(TextEditor, $("##{id}")[0]);
        }());
      </script>
    }.html_safe
  end

  # Inserts a simple text field that let users edit given property (text property).
  def editable_field (object, property, options={})
    update_url = options.delete(:update_url) || url_for(object)
    id = "text-editor-#{property}-#{object.class.to_s.underscore}-#{object.id}"
    prop_name = "#{object.class.to_s.underscore}[#{property}]"
    value = object.send(property)
    %{
      <span id="#{id}"></span>
      <script type="text/javascript">
        (function() {
          var props = {
            data: {
              "#{prop_name}": #{value.to_json}
            },
            updateUrl: "#{update_url}",
            propName: "#{prop_name}",
            placeholder: "#{options[:placeholder]}"
          };
          EditableField = React.createElement(modulejs.require('components/authoring/editable_field'), props);
          ReactDOM.render(EditableField, $("##{id}")[0]);
        }());
      </script>
    }.html_safe
  end

  # The default is hardcoded, here, in place, for the time being. If and
  # when the functionality is extended, the white-list could be located in
  # a more reasonable location in the code-base.
  def default_param_whitelist
    ["mode"]
  end

  # adds "show_index" to the default whitelisted parameters for sequences
  def sequence_param_whitelist
    default_param_whitelist << "show_index"
  end

  def teacher_content
    params['mode'] == 'teacher-edition'
  end

  def append_white_list_params(url_or_path, whitelist=default_param_whitelist)
    # Construct query string from the contents of a url and those parameters
    # that are whitelisted, passing through all the ones in the current url and
    # those in the whitelist that are in the current params.
    #
    # eg:
    #      url_or_path                   => url://localhost/activites/2/?foo=xx
    #      whitelist                     => [:foo, :bar])
    #      params (from the fails route) => {foo:'xx', bar:'yy', bam:'zz', activity:2}
    #
    # yields:
    #      `?foo=xx&bar=yy` (activity and bam are missing)
    
    # If `params` is an instance of `ActionController::Parameters`, use `permit`
    current_params = if params.is_a?(ActionController::Parameters)
      params.permit(whitelist).to_h
    else
      params.slice(*whitelist)
    end

    if current_params.any?
      parsed_url = URI.parse(url_or_path)
      parsed_url_params = Rack::Utils.parse_nested_query(parsed_url.query || '')
      parsed_url.query = current_params.merge(parsed_url_params).to_query
      parsed_url.to_s
    else
      url_or_path
    end
  end

  def svg_icon(path)
    File.open("#{Rails.root}/app#{path}") do |file|
      raw file.read
    end
  end
end
