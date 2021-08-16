{div, img, label, input} = ReactFactories

modulejs.define 'components/itsi_authoring/model_editor',
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
      'mw_interactive[name]': 'name'
      'mw_interactive[url]': 'url'
      'mw_interactive[image_url]': 'image_url'
      'mw_interactive[native_width]': 'native_width'
      'mw_interactive[native_height]': 'native_height'
      'mw_interactive[model_library_url]': 'model_library_url'
      'mw_interactive[authored_state]': 'authored_state'
      'mw_interactive[full_window]': 'full_window'
      'mw_interactive[no_snapshots]': 'no_snapshots'
      'mw_interactive[enable_learner_state]': 'save_interactive_state'

    iframeContainer: React.createRef()
    iframe: React.createRef()

    getInitialState: ->
      modelsByLibraryId: {}
      modelOptions: []
      authoringSupported: false

    initialEditState: ->
      not @props.data.image_url?

    onSelectChange: (key, value) ->
      # Assume that authoring is not supported by default. It might be re-enabled
      # when interactive is loaded and provides features list.
      @setState {authoringSupported: false}
      # update url and image_url when the select changes
      model = @state.modelsByLibraryId[value]
      @valueChanged 'mw_interactive[url]', model.url
      @valueChanged 'mw_interactive[name]', model.name
      @valueChanged 'mw_interactive[image_url]', model.image_url
      @valueChanged 'mw_interactive[native_width]', model.width
      @valueChanged 'mw_interactive[native_height]', model.height
      @valueChanged 'mw_interactive[full_window]', !!model.full_window
      @valueChanged 'mw_interactive[no_snapshots]', !!model.no_snapshots
      @valueChanged 'mw_interactive[enable_learner_state]', !!model.save_interactive_state
      # Reset authored state while switching interactives, as other model probably
      # uses different format and could be broken by old state.
      @valueChanged 'mw_interactive[authored_state]', null

    onAuthoredStateChange: (authoredState) ->
      @valueChanged 'mw_interactive[authored_state]', JSON.stringify(authoredState)

    resetAuthoredState: ->
      @valueChanged 'mw_interactive[authored_state]', null, =>
        # Callback executed when state is updated.
        # Reload iframe to apply "null" initial state.
        @iframe.current.reload()

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
      authoredState = @state.values['mw_interactive[authored_state]']
      (SectionEditorElement {data: @props.data, title: 'Model', toHide: 'mw_interactive[is_hidden]', onEdit: @switchToEditMode, alert: @props.alert, confirmHide: @props.confirmHide},
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
                  src: @state.values['mw_interactive[url]'],
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
            (div {},
              (div {}, @state.values['mw_interactive[name]'])
              (img {src: @state.values['mw_interactive[image_url]'], style: {maxWidth: '800px'}})
            )
          )
      )
