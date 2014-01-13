instances = []

class IFrameSaver
  @instances: []

  constructor: (@$frame, @post_back, @interactive) ->
    IFrameSaver.instances.push @
    @iframePhone      = new Lab.IFramePhone @$frame, null, =>
      console.log  "IFramePone: systems go"
      if @interactive
        @load_interactive()
      @iframePhone.addListener 'interactiveState', (interactive_json) =>
        @interactive = interactive_json
      pull_interactive_json = =>
        @iframePhone.post({ type:'getInteractiveState' })
      setInterval(pull_interactive_json,1000)

  save: () ->
    @iframePhone.post({ type:'getInteractiveState' })
    # We need to do this synchronously somehow in this case...

    console.log "INTERACTIVE_JSON: #{@interactive}"
    debugger
    $.ajax
      type: "POST",
      async: false, #TODO: For now we can only save this synchronously....
      url: @post_back
      data: @interactive
      success: (response) =>
        alert "we saved our interactive"
      error: (jqxhr, status, error) =>
        console.log error

  load_interactive: (interactive_json) ->
    @interactive = interactive_json
    @iframePhone.post({ type:'loadModel', data: { modelId: interactive.models[0].id, modelObject: modelJson } });
    @iframePhone.post({ type:'loadInteractive', data:@interactive  });

$(document).ready ->
  iframe = $("#interactive")[0]
  window.IFrameSaver = IFrameSaver
  window.x = new IFrameSaver(iframe)