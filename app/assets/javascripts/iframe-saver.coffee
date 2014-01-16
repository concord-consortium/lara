instances = []

# IFrameSaver : Wrapper around IFramePhone to save & Load IFrame data
# into interactive_run_state models in LARA.
class IFrameSaver

  @instances:      []  # save-on-change.coffee looks these up.
  @default_data:   $('#interactive_data_div')
  @default_iframe: $("#interactive")[0]

  # @param iframe    : an iframe to save data from.
  # @param $data_div : a qjuery element that includes data-* attributes
  # which describe where we post back to.
  constructor: (iframe=IFrameSaver.default_iframe, $data_div=IFrameSaver.default_data) ->
    @put_url  = $data_div.data('puturl')  # put our data here.
    @get_url  = $data_div.data('geturl')  # read our data from here.

    if (@put_url or @get_url)
      IFrameSaver.instances.push @

    model_did_load = () =>
      if @get_url
        @load_interactive()

    phone_answered = () =>
      @iframePhone.addListener 'interactiveState', (interactive_json) =>
        @save_to_server(interactive_json)
      if @put_url
        #Save interactive every 42 seconds just to be safe:
        window.setInterval (()=> @save()), 42 * 1000

    @iframePhone      = new Lab.IFramePhone(iframe, model_did_load, phone_answered)



  @default_success: ->
    console.log "saved"

  error: (msg) ->
    console.log msg

  save: (success_callback=null) ->
    @success_callback = success_callback

    # will call back into "@save_to_server)
    @iframePhone.post({ type:'getInteractiveState' })

  save_to_server: (interactive_json) ->
    return unless @put_url
    data =
      raw_data: JSON.stringify(interactive_json)
    $.ajax
      type: "PUT"
      async: false #TODO: For now we can only save this synchronously....
      dataType: 'json'
      url: @put_url
      data: data
      success: (response) =>
        if @success_callback
          @success_callback()
        else
          @default_success

      error: (jqxhr, status, error) ->
        @error(error)

  load_interactive: () ->
    data = null
    return unless @get_url
    $.ajax
      url: @get_url
      success: (response) =>
        if response['raw_data']
          interactive = JSON.parse(response['raw_data'])
          @iframePhone.post({ type:'loadInteractive', content:interactive  })

      error: (jqxhr, status, error) =>
        @error(error)

$(document).ready ->
  window.IFrameSaver = IFrameSaver
