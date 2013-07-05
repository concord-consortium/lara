post_to_iframe = (_message) ->
  message = _message
  origin = window.embeddable_origin || "*"
  unless(typeof(message) == 'String')
    message = JSON.stringify(message)
  $('iframe')[0].contentWindow.postMessage(message, origin);


origin = () ->
  document.location.href.match(/(.*?\/\/.*?)\//)[1]

class image_question
  constructor: (@prompt='why do you think...' ,@answer='because ...', @image_url='')->
    @$content         = $('#image_question_answer_form')

    @$content.dialog({
      autoOpen: false,
      width: 800,
      title: "Snapshot",
      modal: true
    })

    @$answer_text     = $('#image_answer_text')

    @$snapshot_button = $('#image_snapshot_button')
    @$done_button     = $('#image_done_button')

    @$delete_button   = $('#image_delete_button')
    @$redo_button     = $('#image_redo_button')
    @$reset_button    = $('#image_reset_button')
    @$cancel_button   = $('#image_cancel_button')

    @create_hooks()

  create_hooks: ->
    @$snapshot_button.click =>
      request_snapshot = {
        'type': 'getInteractiveSnapshot'
        # 'origin': origin()
      }
      post_to_iframe(request_snapshot)
      @show()

    @$cancel_button.click =>
      @cancel()

    @$done_button.click =>
      @hide()
      @save()

  save_failed: ->
    $("#save").html("Save failed!")

  show_saved: ->
    @saveTimer = setTimeout ->
      $("#save").html("Saved.")
      # Fade out.
      $("#save").animate({'opacity': '0'}, 'slow')
    , 1000

  show_saving: ->
    $("#save").html("Saving...")
    $("#save").animate({'opacity': '1.0'}, 'fast')

  cancel: ->
    @hide()

  save: ->
      @show_saving()
      # $(elem).parents('form:first').submit()
      # We should be evaluating the response to that and calling either showSaved() or saveFailed().
      @show_saved();

  show: ->
    @$content.dialog("open");

  hide: () ->
    @$content.dialog("close");


window.ImageQuestion = image_question

snapshot_updater = (e) ->
  data = e.data
  if typeof(data) == 'string'
    data = JSON.parse(data)
  type = data.type
  if type == 'png'
    value = data.values
    image = $('#snapshot_image')
    image.html(value)

hello_handler = (e) ->
  data = e.data
  if typeof(data) == 'string'
    data = JSON.parse(data)
  type = data.type
  window.embeddable_origin = data.origin
  if type == 'hello'
    message =
      type: 'hello',
      origin: origin()
    post_to_iframe(message)

window.addEventListener('message', snapshot_updater, false)
window.addEventListener('message', hello_handler, false)
