instances = []

class IFrameSaver
  @instances: []

  constructor: (@$frame, @$save_button=$("#save_interactive"), @$revert_button=$("#revert_interactive")) ->
    IFrameSaver.instances.push @
    @post_url = @$save_button.data('postBackUrl')
    @get_url  = @$revert_button.data('postBackUrl')

    @iframePhone = new Lab.IFramePhone @$frame, null, =>

      @iframePhone.addListener 'interactiveState', (interactive_json) =>
        @interactive = interactive_json
        @save()

      @$save_button.on 'click', (e) =>
        @iframePhone.post({ type:'getInteractiveState' })

      @$revert_button.on 'click', (e) =>
        @load_interactive()

  error: (msg) ->
    console.log msg

  save: () ->
    data =
      raw_data: JSON.stringify(@interactive)
    $.ajax
      type: "PUT",
      async: false, #TODO: For now we can only save this synchronously....
      dataType: 'json',
      url: @post_url
      data: data
      success: (response) =>
        return
      error: (jqxhr, status, error) =>
        @error(error)

  load_interactive: () ->
    data = null
    $.ajax
      url: @get_url
      success: (response) =>
        if response['raw_data']
          @interactive = JSON.parse(response['raw_data'])
          @iframePhone.post({ type:'loadInteractive', content:@interactive  });

      error: (jqxhr, status, error) =>
        @error(error)


$(document).ready ->
  iframe = $("#interactive")[0]
  window.IFrameSaver = IFrameSaver
  saver = new IFrameSaver(iframe)
