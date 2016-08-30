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
    @put_url = $data_div.data('puturl') # put our data here.
    @get_url = $data_div.data('geturl') # read our data from here.
    @auth_provider = $data_div.data('authprovider') # through which provider did the current user log in
    @user_email = $data_div.data('user-email')
    @logged_in = $data_div.data('loggedin') # true/false - is the current session associated with a user
    @learner_url = null

    @$delete_button.click () =>
      @delete_data()
    @$delete_button.hide()
    @should_show_delete = null
    @saved_state = null
    @autosave_interval_id = null

    @save_indicator = SaveIndicator.instance()

    if (@put_url or @get_url)
      IFrameSaver.instances.push @

    @already_setup = false
    phone_answered = =>
      # Workaround IframePhone problem - phone_answered cabllack can be triggered multiple times:
      # https://www.pivotaltracker.com/story/show/89602814
      return if @already_setup
      @already_setup = true

      @iframePhone.addListener 'setLearnerUrl', (learner_url) =>
        @learner_url = learner_url
      @iframePhone.addListener 'interactiveState', (interactive_json) =>
        if @learner_url
          @save_to_server(interactive_json, @learner_url)
        else
          # wait a bit and try again:
          window.setTimeout( =>
            @save_to_server(interactive_json, @learner_url)
          , 500)
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
      @iframePhone.post('getExtendedSupport')
      @iframePhone.post('getLearnerUrl')

      # Enable autosave after model is loaded. Theoretically we could save empty model before it's loaded,
      # so its state would be lost.
      @load_interactive =>
        @set_autosave_enabled(true)

    @iframePhone = IframePhoneManager.getPhone($iframe[0], phone_answered)

  @default_success: ->
    console.log "saved"

  error: (msg) ->
    @save_indicator.showSaveFailed(msg)

  save: (success_callback = null) ->
    @success_callback = success_callback

    # will call back into "@save_to_server)
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
      @learner_url = null
      @save_to_server(null, "")

  save_to_server: (interactive_json, learner_url) ->
    return unless @put_url

    runSuccess = =>
      @saved_state = interactive_json
      if @success_callback
        @success_callback()
      else
        @default_success

    # Do not send the same state to server over and over again.
    # "nochange" is a special type of response from CODAP.
    if JSON.stringify(interactive_json) == JSON.stringify(@saved_state) || interactive_json is "nochange"
      runSuccess()
      return

    @save_indicator.showSaving()
    data =
      raw_data: JSON.stringify(interactive_json)
      learner_url: learner_url
    $.ajax
      type: 'PUT'
      dataType: 'json'
      url: @put_url
      data: data
      success: (response) =>
        runSuccess()
        @save_indicator.showSaved("Saved Interactive")
      error: (jqxhr, status, error) =>
        @error("couldn't save interactive")

  load_interactive: (callback) ->
    unless @get_url
      callback()
      return

    # this is the newer method of initializing an interactive
    # it returns the current state and linked state
    init_interactive = (err, response) =>
      loc = window.location
      @iframePhone.post 'initInteractive',
        version: 1,
        error: err
        interactiveState: if response?.raw_data then JSON.parse(response.raw_data) else null
        hasLinkedInteractive: response?.has_linked_interactive or false
        linkedState: if response?.linked_state then JSON.parse(response.linked_state) else null
        interactiveStateUrl: "#{loc.protocol}//#{loc.hostname}#{if loc.port then ":#{loc.port}" else ""}#{@get_url}"

    $.ajax
      url: @get_url
      success: (response) =>
        if response['raw_data']
          interactive = JSON.parse(response['raw_data'])
          if interactive
            @saved_state = interactive
            @iframePhone.post({type: 'loadInteractive', content: interactive})
            # Lab logging needs to be re-enabled after interactive is (re)loaded.
            LoggerUtils.enableLabLogging @$iframe[0]
            @$delete_button.show() if @should_show_delete == null or @should_show_delete
        init_interactive null, response
      error: (jqxhr, status, error) =>
        init_interactive "couldn't load interactive"
        @error("couldn't load interactive")
      complete: =>
        callback()

  set_autosave_enabled: (v) ->
    return unless @put_url
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
