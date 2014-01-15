instances = []

class IFrameSaver
  @instances: []

  constructor: (@$frame, @$save_button=$("#save_interactive"), @$revert_button=$("#revert_interactive")) ->
    IFrameSaver.instances.push @
    @post_url = @$save_button.data('postBackUrl')
    @get_url  = @$revert_button.data('postBackUrl')

    @iframePhone = new Lab.IFramePhone @$frame, =>
        @load_interactive()
      , =>
        console.log  "IFramePone: systems go"
        @iframePhone.addListener 'interactiveState', (interactive_json) =>
          @interactive = interactive_json
          @save()

      @$save_button.on 'click', (e) =>
        @iframePhone.post({ type:'getInteractiveState' })

      @$revert_button.on 'click', (e) =>
        @load_interactive()
      # pull_interactive_json = =>
      #   @iframePhone.post({ type:'getInteractiveState' })
      # setInterval(pull_interactive_json,1000)

  save: () ->
    data =
      raw_data: @interactive
    $.ajax
      type: "PUT",
      async: false, #TODO: For now we can only save this synchronously....
      url: @post_url
      data: JSON.stringify(data)
      contentType: "application/json; charset=utf-8",
      dataType: "json",
      success: (response) =>
        alert "we saved our interactive"
      error: (jqxhr, status, error) =>
        console.log error

  load_interactive: () ->
    data = null
    $.ajax
      url: @get_url
      success: (response) =>
        if response['raw_data']
          @interactive = JSON.parse(response['raw_data'])
          url = @interactive.models[0].url
          @interactive.models[0].url = "http://lab.concord.org/#{url}"
          alert "we loaded our interactive"

      error: (jqxhr, status, error) =>
        # debugger
        console.log error


$(document).ready ->
  iframe = $("#interactive")[0]
  window.IFrameSaver = IFrameSaver
  saver = new IFrameSaver(iframe)
