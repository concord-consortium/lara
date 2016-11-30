{div, img, label, input} = React.DOM

modulejs.define 'components/itsi_authoring/model_editor',
[
  'components/itsi_authoring/section_element_editor_mixin',
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/section_editor_element',
  'components/authoring/interactive_iframe',
  'components/itsi_authoring/cached_ajax'
],
(
  SectionElementEditorMixin,
  SectionEditorFormClass,
  SectionEditorElementClass,
  InteractiveIframeClass,
  cachedAjax
) ->

  SectionEditorForm = React.createFactory SectionEditorFormClass
  SectionEditorElement = React.createFactory SectionEditorElementClass
  InteractiveIframe = React.createFactory InteractiveIframeClass

  ModelEditor = React.createClass

    mixins:
      [SectionElementEditorMixin]

    # maps form names to @props.data keys
    dataMap:
      'mw_interactive[name]': 'name'
      'mw_interactive[url]': 'url'
      'mw_interactive[image_url]': 'image_url'
      'mw_interactive[native_width]': 'native_width'
      'mw_interactive[native_height]': 'native_height'
      'mw_interactive[model_library_url]': 'model_library_url'
      'mw_interactive[authored_state]': 'authored_state'

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
      # Reset authored state while switching interactives, as other model probably
      # uses different format and could be broken by old state.
      @valueChanged 'mw_interactive[authored_state]', null

    onAuthoredStateChange: (authoredState) ->
      @valueChanged 'mw_interactive[authored_state]', JSON.stringify(authoredState)

    resetAuthoredState: ->
      @valueChanged 'mw_interactive[authored_state]', null, =>
        # Callback executed when state is updated.
        # Reload iframe to apply "null" initial state.
        @refs.iframe.reload()

    handleSupportedFeaturesUpdate: (info) ->
      @setState {authoringSupported: !!info.features.authoredState}

    fetchModelList: ->
      url = @props.jsonListUrls?.models or 'https://s3.amazonaws.com/sensorconnector-s3.concord.org/model_list.json'
      cachedAjax
        url: url
        success: (data) =>
          if @isMounted()
            models = data?.models
            modelOptions = []
            modelsByLibraryId = {}

            if models
              models.sort (a, b) ->
                [lowerA, lowerB] = [a.name?.toLowerCase(), b.name?.toLowerCase()]
                return -1 if lowerA < lowerB
                return 1 if lowerA > lowerB
                return 0
              for model, i in models
                # e.g. https://itsi.portal.concord.org/interactives/export_model_library#123
                libraryId = url + '#' + model.id
                modelsByLibraryId[libraryId] = model
                modelOptions.push
                  name: if model.id then "#{model.id}: #{model.name}" else model.name
                  value: libraryId

            @setState
              modelOptions: modelOptions
              modelsByLibraryId: modelsByLibraryId

    switchToEditMode: ->
      @fetchModelList() if @state.modelOptions.length == 0
      @edit()

    render: ->
      authorable = @state.authoringSupported
      authoredState = @state.values['mw_interactive[authored_state]']
      (SectionEditorElement {data: @props.data, title: 'Model', toHide: 'mw_interactive[is_hidden]', onEdit: @switchToEditMode, alert: @props.alert, confirmHide: @props.confirmHide},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (label {}, 'Model')
            if @state.modelOptions.length > 0
              (@select {name: 'mw_interactive[model_library_url]', options: @state.modelOptions, onChange: @onSelectChange})
            else
              'Loading models...'

            (div {className: "ia-interactive-container #{unless authorable then 'not-authorable' else ''}"},
              if authorable
                (div {className: 'ia-authoring-status'},
                  'This interactive can be customized. '
                  if authoredState
                    (input {type: 'button', className: 'ia-reset-authored-state', value: 'Reset authored state', onClick: @resetAuthoredState})
                )
              (div {className: 'ia-interactive'},
                (InteractiveIframe
                  ref: 'iframe'
                  src: @state.values['mw_interactive[url]'],
                  initialAuthoredState: authoredState,
                  onAuthoredStateChange: @onAuthoredStateChange
                  onSupportedFeaturesUpdate: @handleSupportedFeaturesUpdate
                )
                unless authorable
                 (div {className: 'ia-interactive-overlay'})
              )
            )
          )
        else
          (div {className: 'ia-section-text'},
            if @state.values['mw_interactive[name]']
              (div {},
                (div {}, @state.values['mw_interactive[name]'])
                (img {src: @state.values['mw_interactive[image_url]'], style: {maxWidth: '800px'}})
              )
            else
              'No model selected'
          )
      )
