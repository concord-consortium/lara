getAuthoredState = ($dataDiv) ->
  authoredState = $dataDiv.data('authored-state')
  if !authoredState? || authoredState == ''
    authoredState = null
  if typeof authoredState == 'string'
    authoredState = JSON.parse(authoredState)
  authoredState

#FIXME: this was added quickly to test out preloading state
getRuntimeState = ($dataDiv) ->
  authoredState = $dataDiv.data('runtime-state')
  if !authoredState? || authoredState == ''
    authoredState = null
  if typeof authoredState == 'string'
    authoredState = JSON.parse(authoredState)
  authoredState


interactiveStateProps = (data) ->
  interactiveState: if data?.raw_data then JSON.parse(data.raw_data) else null
  hasLinkedInteractive: data?.has_linked_interactive
  linkedState: if data?.linked_state then JSON.parse(data.linked_state) else undefined
  allLinkedStates: if data?.all_linked_states then data.all_linked_states.map(interactiveStateProps) else undefined
  createdAt: data?.created_at
  updatedAt: data?.updated_at
  interactiveStateUrl: data?.interactive_state_url
  interactive:
    # Keep default values `undefined` (data?.something returns undefined if data is not available),
    # as they might be obtained the other way. See "init_interactive" function which extends basic data using object
    # returned from this one. `undefined` ensures that we won't overwrite a valid value.
    id: data?.interactive_id
    name: data?.interactive_name
  pageNumber: data?.page_number
  pageName: data?.page_name
  activityName: data?.activity_name

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
    @get_firebase_jwt_url = $data_div.data('get-firebase-jwt-url')

    @save_indicator = SaveIndicator.instance()

    @$delete_button.click () =>
      @delete_data()

    @saved_state = null
    @autosave_interval_id = null

    # FIXME: this is just a quick hack to test this out
    @runtimeState = getRuntimeState($data_div)

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
    @iframePhone.addListener 'height', (height) =>
      @$iframe.data('height', height)
      @$iframe.trigger('sizeUpdate')
    @iframePhone.addListener 'supportedFeatures', (info) =>
      if info.features?.aspectRatio?
        # If the author specifies the aspect-ratio-method as "DEFAULT"
        # then the Interactive can provide suggested aspect-ratio.
        if(@$iframe.data('aspect-ratio-method') == "DEFAULT")
          @$iframe.data('aspect-ratio', info.features.aspectRatio)
          @$iframe.trigger('sizeUpdate')

    @iframePhone.addListener 'navigation', (opts={})=>
      if opts.hasOwnProperty('enableForwardNav')
        if opts.enableForwardNav
          ForwardBlocker.instance.enable_forward_navigation_for(@$iframe[0])
        else
          ForwardBlocker.instance.prevent_forward_navigation_for(@$iframe[0], opts.message)
    @iframePhone.addListener 'getFirebaseJWT', (opts={}) =>
      @get_firebase_jwt(opts)

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
        # State has been saved. Show "Undo all my work" button.
        @$delete_button.show()
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

    # FIXME: this is just a quick hack to test this out
    if @runtimeState
      response = @runtimeState
      if response['raw_data']
        interactive = JSON.parse(response['raw_data'])
        if interactive
          @saved_state = interactive
          # DEPRECATED: the initInteractive message includes the interactive state so
          # interactives should use the initInteractive method instead
          @iframePhone.post({type: 'loadInteractive', content: interactive})
          # Lab logging needs to be re-enabled after interactive is (re)loaded.
          LoggerUtils.enableLabLogging @$iframe[0]
          # State is available. Show "Undo all my work" button.
          @$delete_button.show()
      @init_interactive null, response
      callback()
      return

    $.ajax
      url: @interactive_run_state_url
      success: (response) =>
        if response['raw_data']
          interactive = JSON.parse(response['raw_data'])
          if interactive
            @saved_state = interactive
            # DEPRECATED: the initInteractive message includes the interactive state so
            # interactives should use the initInteractive method instead
            @iframePhone.post({type: 'loadInteractive', content: interactive})
            # Lab logging needs to be re-enabled after interactive is (re)loaded.
            LoggerUtils.enableLabLogging @$iframe[0]
            # State is available. Show "Undo all my work" button.
            @$delete_button.show()
        @init_interactive null, response
      error: (jqxhr, status, error) =>
        @init_interactive "couldn't load interactive"
        @error("couldn't load interactive")
      complete: =>
        callback()

  # this is the newer method of initializing an interactive
  # it returns the current state and linked state
  init_interactive: (err = null, response = null) ->
    init_interactive_msg =
      version: 1
      error: err
      mode: 'runtime'
      authoredState: @authoredState
      # See: global-iframe-saver.coffee
      globalInteractiveState: if globalIframeSaver? then globalIframeSaver.globalState else null
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
    # Perhaps it would be nicer to keep `interactiveStateProps` in some separate property instead of mixing
    # it directly into general init message. However, multiple interactives are already using this format
    # and it doesn't seem to be worth changing at this point.
    $.extend(true, init_interactive_msg, interactiveStateProps(response))

    @iframePhone.post 'initInteractive', init_interactive_msg

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

  get_firebase_jwt: (opts) ->
    $.ajax
      type: 'POST'
      url: @get_firebase_jwt_url
      data: opts
      success: (response) =>
        @iframePhone.post 'firebaseJWT', response
      error: (jqxhr, status, error) =>
        @iframePhone.post 'firebaseJWT', {response_type: "ERROR", message: error}

# Export constructor.
window.IFrameSaver = IFrameSaver
