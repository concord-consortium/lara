{div, span, h2} = ReactFactories

modulejs.define 'components/authoring/editable_field',
[
  'components/common/ajax_form_mixin'
],
(
  AjaxFormMixin
) ->

  EditableField = createReactClass
    mixins:
      [AjaxFormMixin]

    currentText: ->
      @state.values[@props.propName] || @props.placeholder

    render: ->
      (div {className: "authoring-text-field #{if @state.edit then 'edit' else ''}"},
        if @state.edit
          (@text {name: @props.propName})
        else
          (span {}, @currentText())
        (span {className: 'text-field-links'},
          if @state.edit
            (span {},
              (span {onClick: @save}, 'Save')
              '|'
              (span {onClick: @cancel}, 'Cancel')
            )
          else
            (span {onClick: @edit}, 'Edit')
        )
      )
