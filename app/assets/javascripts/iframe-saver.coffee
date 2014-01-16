instances = []

class IFrameSaver
  @instances: []

  constructor: (@$frame, @$data_div=$('#interactive_data_div')) ->
    return unless @$frame
    @put_url  = $(@$data_div).data('puturl')
    @get_url  = $(@$data_div).data('geturl')
    if (@put_url or @get_url)
      IFrameSaver.instances.push @
    @iframePhone = new Lab.IFramePhone @$frame, =>
      @load_interactive()
    , =>
      @iframePhone.addListener 'interactiveState', (interactive_json) =>
        @interactive = interactive_json
        @save_to_server()
    @success_callback= ->
      console.log "saved"
    @error_callback = @error

  error: (msg) ->
    console.log msg

  save: (success_callback=@save_success, error_callback=@error) ->
    @success_callback = success_callback
    @error_callback = error_callback
    @iframePhone.post({ type:'getInteractiveState' })

  save_to_server: () ->
    return unless @put_url
    data =
      raw_data: JSON.stringify(@interactive)
    $.ajax
      type: "PUT"
      async: false #TODO: For now we can only save this synchronously....
      dataType: 'json'
      url: @put_url
      data: data
      success: (response) =>
        @success_callback()

      error: (jqxhr, status, error) ->
        @error_callback

  load_interactive: () ->
    data = null
    return unless @get_url
    $.ajax
      url: @get_url
      success: (response) =>
        if response['raw_data']
          @interactive = JSON.parse(response['raw_data'])
          @iframePhone.post({ type:'loadInteractive', content:@interactive  })

      error: (jqxhr, status, error) =>
        @error(error)

$(document).ready ->
  iframe = $("#interactive")[0]
  window.IFrameSaver = IFrameSaver
  saver = new IFrameSaver(iframe)
