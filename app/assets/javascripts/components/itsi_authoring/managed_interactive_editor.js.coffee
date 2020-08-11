{div, img, label, input, textarea} = ReactFactories

modulejs.define 'components/itsi_authoring/managed_interactive_editor',
[
  'components/common/ajax_form_mixin',
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/section_editor_element',
  'components/itsi_authoring/cached_ajax',
  'components/itsi_authoring/tiny_mce_config'
],
(
  AjaxFormMixin,
  SectionEditorFormClass,
  SectionEditorElementClass,
  cachedAjax,
  ITSITinyMCEConfig
) ->

  SectionEditorForm = React.createFactory SectionEditorFormClass
  SectionEditorElement = React.createFactory SectionEditorElementClass

  ModelEditor = createReactClass

    mixins:
      [AjaxFormMixin]

    # maps form names to @props.data keys
    dataMap:
      'managed_interactive[authored_state]': 'authored_state'

    getInitialState: ->
      authored_state = JSON.parse(@props.data.authored_state)
      prompt: authored_state.prompt
      defaultAnswer: authored_state.defaultAnswer
      authoringSupported: true

    initialEditState: ->
      (JSON.parse(@props.data.authored_state).prompt?.length or 0) is 0

    updateAuthoredState: (authoredState) ->
      @valueChanged 'managed_interactive[authored_state]', JSON.stringify(authoredState)

    switchToEditMode: ->
      @state.values['managed_interactive[prompt]'] = @state.prompt
      @state.values['managed_interactive[defaultAnswer]'] = @state.defaultAnswer
      @edit()

    managedInteractiveSave: (e) ->
      e?.preventDefault()
      authored_state = JSON.parse(@props.data.authored_state)
      if @state.changedValues['managed_interactive[prompt]']
        @state.prompt = @state.values['managed_interactive[prompt]']
        authored_state.prompt = @state.prompt
        delete @state.changedValues['managed_interactive[prompt]']
      if @state.changedValues['managed_interactive[defaultAnswer]']
        @state.defaultAnswer = @state.values['managed_interactive[defaultAnswer]']
        authored_state.defaultAnswer = @state.defaultAnswer
        delete @state.changedValues['managed_interactive[defaultAnswer]']
      @updateAuthoredState authored_state
      @save?()

    render: ->
      console.log(@state.values)
      authorable = @state.authoringSupported
      (SectionEditorElement {data: @props.data, title: 'Managed Interactive', toHide: 'managed_interactive[is_hidden]', onEdit: @switchToEditMode, alert: @props.alert, confirmHide: @props.confirmHide},
        if @state.edit
          (SectionEditorForm {onSave: @managedInteractiveSave, onCancel: @cancel},
            (div {className: "ia-interactive-container #{unless authorable then 'not-authorable' else ''}"},
              (label {}, 'Question prompt')
              (@richText {name: 'managed_interactive[prompt]', TinyMCEConfig: ITSITinyMCEConfig})

              (label {}, 'Default text in answer area')
              (@text {name: 'managed_interactive[defaultAnswer]'})
            )
          )
        else
          (div {className: 'ia-section-text'},
            (div {className: 'ia-section-text-value', dangerouslySetInnerHTML: {__html: @state.prompt}})
            (textarea {value: @state.defaultAnswer, disabled: 'disabled'})
          )
      )
