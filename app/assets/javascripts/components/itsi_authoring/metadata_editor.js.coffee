{div} = React.DOM

modulejs.define 'components/itsi_authoring/metadata_editor',
['components/itsi_authoring/form_mixin'],
(FormMixin) ->

  React.createClass
    mixins: [FormMixin]

    updateUrl: ->
      @props.initialData.update_url

    render: ->
      data = @props.initialData
      (div {className: 'ia-metadata-editor'},
        (div {className: 'ia-label'}, 'Activity name')
        (@input {type: 'text', name: 'lightweight_activity[name]', defaultValue: @props.metadata.name})
        (div {className: 'ia-label'}, 'Activity description')
        (@textarea name: {'lightweight_activity[description]', defaultValue: @props.metadata.description})
        (div {className: 'ia-label'},
          @saveButton()
        )
      )

###

In https://github.com/concord-consortium/rigse/blob/itsisu-dev/app/views/activities/template_edit.html.haml

these fields exist but don't seem to in LARA:

  %h3 publication status
  = f.select :publication_status, activity_status_options
  - if current_user.has_role?('admin','manager')
    %h3 exemplar activity
    = f.check_box :is_exemplar
  %h3 grade level:
  = grade_level_select
  %h3 subject area:
  = subject_area_select
  %h3 unit:
  = unit_select

###
