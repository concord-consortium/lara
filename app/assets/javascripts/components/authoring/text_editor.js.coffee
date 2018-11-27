{div, span, h2} = ReactFactories

modulejs.define 'components/authoring/text_editor',
[
  'components/common/rich_text_editor',
  'components/common/ajax_form_mixin'
],
(
  RichTextEditorClass,
  AjaxFormMixin
) ->

  RichTextEditor = React.createFactory RichTextEditorClass

  TextEditor = createReactClass
    mixins:
      [AjaxFormMixin]

    currentText: ->
      @state.values[@props.textPropName]

    currentHeader: ->
      @state.values[@props.headerPropName]

    render: ->
      (div {className: "authoring-text-editor #{if @state.edit then 'edit' else ''}"},
        (h2 {},
          if @state.edit && @props.editableHeader
            (span {className: 'header-edit'}, (@text {name: @props.headerPropName}))
          else
            @currentHeader()
          (div {className: 'authoring-text-links'},
            if @state.edit
              (span {},
                (span {onClick: @save}, 'Save')
                ' | '
                (span {onClick: @cancel}, 'Cancel')
              )
            else
              (span {onClick: @edit}, 'Edit')
          )
        )
        if @state.edit
          (div {className: "authoring-tinymce"},
            (@richText {name: @props.textPropName})
          )
        (div {className: 'authoring-text-content', dangerouslySetInnerHTML: {__html: @currentText()}})
      )
