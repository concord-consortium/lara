instances = []

class IFrameSaver
  @instances: []

  constructor: (@$frame, @$save_button=$("#save_interactive"), @revert_button=$("#revert_interactive")) ->
    IFrameSaver.instances.push @
    @url = @$save_button.data('postBackUrl')

    @iframePhone = new Lab.IFramePhone @$frame, null, =>
      console.log  "IFramePone: systems go"
      if @interactive
        @load_interactive()
      @iframePhone.addListener 'interactiveState', (interactive_json) =>
        @interactive = interactive_json
        @save()

    @$save_button.on 'click', (e) =>
      @iframePhone.post({ type:'getInteractiveState' })

      # pull_interactive_json = =>
      #   @iframePhone.post({ type:'getInteractiveState' })
      # setInterval(pull_interactive_json,1000)

  save: () ->
    console.log "INTERACTIVE_JSON: #{@interactive}"
    data =
      raw_data: @interactive
    $.ajax
      type: "PUT",
      async: false, #TODO: For now we can only save this synchronously....
      url: @url
      data: JSON.stringify(data)
      contentType: "application/json; charset=utf-8",
      dataType: "json",
      success: (response) =>
        alert "we saved our interactive"
      error: (jqxhr, status, error) =>
        console.log error

  load_interactive: (interactive_json) ->
    @interactive = interactive_json
    @iframePhone.post({ type:'loadInteractive', data:@interactive  });

$(document).ready ->
  iframe = $("#interactive")[0]
  window.IFrameSaver = IFrameSaver
  saver = new IFrameSaver(iframe)
