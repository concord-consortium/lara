getAuthoredState = ($dataDiv) ->
  authoredState = $dataDiv.data('authored-state')
  if !authoredState? || authoredState == ''
    authoredState = null
  if typeof authoredState == 'string'
    authoredState = JSON.parse(authoredState)
  authoredState

parseLinkedStateMetadata = (metadataArray) ->
  metadataArray.map (metadata) ->
    interactiveId: metadata.interactive_id
    data: JSON.parse(metadata.data)
    createdAt: metadata.created_at
    updatedAt: metadata.updated_at

# IFrameSaver : Wrapper around IFramePhone to save & Load IFrame data
# into interactive_run_state models in LARA.
class IFrameSaver
  @instances: []  # save-on-change.coffee looks these up.

  # @param iframe         : an iframe to save data from (jQuery)
  # @param $data_div      : an element that includes data-* attributes which describe where we post back to (jQuery)
  # @param $delete_button : an element that is used to trigger data deletion on click (jQuery)
  constructor: ($iframe, $data_div, $delete_button) ->
    @$iframe = $iframe
    @$delete_button = $delete_button
    @enable_learner_state = $data_div.data('enable-learner-state');
    @interactive_run_state_url = $data_div.data('interactive-run-state-url') # get and put our data here.
    @collaborator_urls = $data_div.data('collaborator-urls')
    @auth_provider = $data_div.data('authprovider') # through which provider did the current user log in
    @user_email = $data_div.data('user-email')
    @logged_in = $data_div.data('loggedin') # true/false - is the current session associated with a user
    @authoredState = getAuthoredState($data_div) # state / configuration provided during authoring
    @class_info_url = $data_div.data('class-info-url')
    @interactive_id = $data_div.data('interactive-id')
    @interactive_name = $data_div.data('interactive-name')

    @$delete_button.click () =>
      @delete_data()
    @$delete_button.hide()
    @should_show_delete = null
    @saved_state = null
    @autosave_interval_id = null

    @save_indicator = SaveIndicator.instance()

    if @learner_state_saving_enabled()
      IFrameSaver.instances.push @

    @already_setup = false

    @iframePhone = IframePhoneManager.getPhone($iframe[0], => @phone_answered())

  @default_success: ->
    console.log "saved"

  phone_answered: ->
    # Workaround IframePhone problem - phone_answered cabllack can be triggered multiple times:
    # https://www.pivotaltracker.com/story/show/89602814
    return if @already_setup
    @already_setup = true

    @iframePhone.addListener 'setLearnerUrl', (learner_url) =>
      @save_learner_url(learner_url)
    @iframePhone.addListener 'interactiveState', (interactive_json) =>
      @save_learner_state(interactive_json)
    @iframePhone.addListener 'getAuthInfo', =>
      authInfo = {provider: @auth_provider, loggedIn: @logged_in}
      if @user_email?
        authInfo.email = @user_email
      @iframePhone.post('authInfo', authInfo)
    @iframePhone.addListener 'extendedSupport', (opts)=>
      if opts.reset?
        @should_show_delete = opts.reset
        if @saved_state
          if @should_show_delete
            @$delete_button.show()
          else
            @$delete_button.hide()
    @iframePhone.addListener 'navigation', (opts={})=>
      if opts.hasOwnProperty('enableForwardNav')
        if opts.enableForwardNav
          ForwardBlocker.instance.enable_forward_navigation_for(@$iframe[0])
        else
          ForwardBlocker.instance.prevent_forward_navigation_for(@$iframe[0], opts.message)
    @iframePhone.post('getExtendedSupport')

    if @learner_state_saving_enabled()
      @iframePhone.post('getLearnerUrl')

    # Enable autosave after model is loaded. Theoretically we could save empty model before it's loaded,
    # so its state would be lost.
    @load_interactive =>
      @set_autosave_enabled(true)

  error: (msg) ->
    @save_indicator.showSaveFailed(msg)

  learner_state_saving_enabled: ->
    @enable_learner_state && @interactive_run_state_url

  save: (success_callback = null) ->
    @success_callback = success_callback
    # will call back into "@save_learner_state)
    @iframePhone.post({type: 'getInteractiveState'})

  confirm_delete: (callback) ->
    if (window.confirm("Are you sure you want to restart your work in this model?"))
      callback()

  delete_data: () ->
    # Disable autosave, as it's possible that autosave will be triggered *after* we send to server "null" state
    # (delete it). Actually it used to happen quite ofted.
    @set_autosave_enabled(false)

    @success_callback = () =>
      window.location.reload()
    @confirm_delete () =>
      @save_learner_state(null)
      @save_learner_url("")

  save_learner_state: (interactive_json) ->
    return unless @learner_state_saving_enabled()

    runSuccess = =>
      @saved_state = interactive_json
      if @success_callback
        @success_callback()
      else
        @default_success

    # Do not send the same state to server over and over again.
    # "nochange" is a special type of response.
    # "touch" is an another special type of response which will triger timestamp update only.
    if interactive_json isnt "touch" && (interactive_json is "nochange" || JSON.stringify(interactive_json) == JSON.stringify(@saved_state))
      runSuccess()
      return

    @save_indicator.showSaving()
    $.ajax
      type: 'PUT'
      dataType: 'json'
      url: @interactive_run_state_url
      data:
        if interactive_json is "touch" then {} else { raw_data: JSON.stringify(interactive_json) }
      success: (response) =>
        runSuccess()
        @save_indicator.showSaved("Saved Interactive")
      error: (jqxhr, status, error) =>
        @error("couldn't save interactive")

  save_learner_url: (learner_url) ->
    return unless @learner_state_saving_enabled()
    $.ajax
      type: 'PUT'
      dataType: 'json'
      url: @interactive_run_state_url
      data:
        learner_url: learner_url
      error: (jqxhr, status, error) =>
        @error("couldn't save learner url")

  load_interactive: (callback) ->
    unless @learner_state_saving_enabled()
      @init_interactive()
      callback()
      return

    $.ajax
      url: @interactive_run_state_url
      success: (response) =>
        if response['raw_data']
          interactive = JSON.parse(response['raw_data'])
          if interactive
            @saved_state = interactive
            @iframePhone.post({type: 'loadInteractive', content: interactive})
            # Lab logging needs to be re-enabled after interactive is (re)loaded.
            LoggerUtils.enableLabLogging @$iframe[0]
            @$delete_button.show() if @should_show_delete == null or @should_show_delete
        @init_interactive null, response
      error: (jqxhr, status, error) =>
        @init_interactive "couldn't load interactive"
        @error("couldn't load interactive")
      complete: =>
        callback()

  # this is the newer method of initializing an interactive
  # it returns the current state and linked state
  init_interactive: (err = null, response = null) ->

    @iframePhone.post 'initInteractive',
      version: 1
      error: err
      mode: 'runtime'
      authoredState: @authoredState
      interactiveState: if response?.raw_data then JSON.parse(response.raw_data) else null
      interactiveStateCreatedAt: response?.created_at
      interactiveStateUpdatedAt: response?.updated_at
      # See: global-iframe-saver.coffee
      globalInteractiveState: if globalIframeSaver? then globalIframeSaver.globalState else null
      hasLinkedInteractive: response?.has_linked_interactive or false
      linkedState: if response?.linked_state then JSON.parse(response.linked_state) else null
      allLinkedStates: if response?.all_linked_states then parseLinkedStateMetadata(response.all_linked_states) else []
      interactiveStateUrl: @interactive_run_state_url
      collaboratorUrls: if @collaborator_urls? then @collaborator_urls.split(';') else null
      classInfoUrl: @class_info_url
      interactive:
        id: @interactive_id
        name: @interactive_name
      authInfo:
        provider: @auth_provider
        loggedIn: @logged_in
        email: @user_email

  set_autosave_enabled: (v) ->
    return unless @learner_state_saving_enabled()
    # Save interactive every 5 seconds, on window focus and iframe mouseout just to be safe.
    # Focus event is attached to the window, so it has to have unique namespace. Mouseout is attached to the iframe
    # itself, but other code can use that event too (e.g. logging).
    namespace = "focus.iframe_saver_#{@$iframe.data('id')}"
    focus_namespace = "focus.#{namespace}"
    mouseout_namespace = "mouseout.#{namespace}"
    if v
      @autosave_interval_id = setInterval (=> @save()), 5 * 1000
      $(window).on focus_namespace, => @save()
      @$iframe.on mouseout_namespace, => @save()
    else
      clearInterval(@autosave_interval_id) if @autosave_interval_id
      $(window).off focus_namespace
      @$iframe.off mouseout_namespace


# Export constructor.
window.IFrameSaver = IFrameSaver
