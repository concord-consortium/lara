{div, img, label, input} = ReactFactories

modulejs.define 'components/itsi_authoring/managed_interactive_editor',
[
  'components/common/ajax_form_mixin',
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/section_editor_element',
  'components/common/interactive_iframe',
  'components/itsi_authoring/cached_ajax'
],
(
  AjaxFormMixin,
  SectionEditorFormClass,
  SectionEditorElementClass,
  InteractiveIframeClass,
  cachedAjax
) ->

  SectionEditorForm = React.createFactory SectionEditorFormClass
  SectionEditorElement = React.createFactory SectionEditorElementClass
  InteractiveIframe = React.createFactory InteractiveIframeClass

  ModelEditor = createReactClass

    mixins:
      [AjaxFormMixin]

    # maps form names to @props.data keys
    dataMap:
      'managed_interactive[authored_state]': 'authored_state'

    iframeContainer: React.createRef()
    iframe: React.createRef()

    getInitialState: ->
      modelOptions: []
      authoringSupported: true

    initialEditState: ->
      true

    onAuthoredStateChange: (authoredState) ->
      @valueChanged 'managed_interactive[authored_state]', JSON.stringify(authoredState)

    handleHeightChange: (height) ->
      container = @iframeContainer.current
      container.style.height = height + 'px'

    handleSupportedFeaturesUpdate: (info) ->
      @setState {authoringSupported: !!info.features.authoredState}
      if (info.features.aspectRatio?)
        container = @iframeContainer.current
        container.style.height = Math.round(container.offsetWidth / info.features.aspectRatio) + 'px'

    switchToEditMode: ->
      @edit()

    render: ->
      authorable = @state.authoringSupported
      authoredState = @state.values['managed_interactive[authored_state]']
      (SectionEditorElement {data: @props.data, title: 'Model', toHide: 'managed_interactive[is_hidden]', onEdit: @switchToEditMode, alert: @props.alert, confirmHide: @props.confirmHide},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (label {}, 'Model')
            (div {className: "ia-interactive-container #{unless authorable then 'not-authorable' else ''}"},
              if authorable
                (div {className: 'ia-authoring-status'},
                  'This interactive can be customized. '
                  if authoredState
                    (input {type: 'button', className: 'ia-reset-authored-state', value: 'Reset authored state', onClick: @resetAuthoredState})
                )
              (div {className: 'ia-interactive', ref: @iframeContainer},
                (InteractiveIframe
                  ref: @iframe
                  src: @state.values['managed_interactive[url]'],
                  initMsg: {
                    version: 1
                    error: null
                    mode: 'authoring'
                    authoredState: authoredState
                  }
                  onAuthoredStateChange: @onAuthoredStateChange
                  onSupportedFeaturesUpdate: @handleSupportedFeaturesUpdate
                  onHeightChange: @handleHeightChange
                )
                unless authorable
                 (div {className: 'ia-interactive-overlay'})
              )
            )
          )
        else
          (div {className: 'ia-section-text'},
            'Preview coming soon.'
          )
      )
