{div, img, label} = ReactFactories

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

  ManagedInteractiveEditor = createReactClass

    mixins:
      [AjaxFormMixin]

    # maps form names to @props.data keys
    dataMap:
      'managed_interactive[authored_state]': 'authored_state'
      'managed_interactive[url]': 'url'

    iframeContainer: React.createRef()
    iframe: React.createRef()

    getInitialState: ->
      modelOptions: []

    initialEditState: ->
      false

    onAuthoredStateChange: (authoredState) ->
      @valueChanged 'managed_interactive[authored_state]', JSON.stringify(authoredState)

    handleHeightChange: (height) ->
      container = @iframeContainer.current
      container.style.height = height + 'px'

    handleSupportedFeaturesUpdate: (info) ->
      if (info.features.aspectRatio?)
        container = @iframeContainer.current
        container.style.height = Math.round(container.offsetWidth / info.features.aspectRatio) + 'px'

    switchToEditMode: ->
      @edit()

    render: ->
      authoredState = @state.values['managed_interactive[authored_state]']
      (SectionEditorElement {data: @props.data, title: @props.data.name, toHide: 'managed_interactive[is_hidden]', onEdit: @switchToEditMode, alert: @props.alert, confirmHide: @props.confirmHide},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (label {}, @props.data.name)

            (div {className: "ia-interactive-container"},
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
              )
            )
          )
        else
          (div {className: 'ia-interactive-container'},
            (div {className: 'ia-interactive', ref: @iframeContainer},
              (InteractiveIframe
                ref: @iframe
                src: @state.values['managed_interactive[url]'],
                initMsg: {
                  version: 1
                  error: null
                  mode: 'runtime'
                  authoredState: authoredState
                }
                onHeightChange: @handleHeightChange
              )
            )
          )
      )
