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
    @current_src = $("[name='embeddable_image_question_answer[image_url]']").val()
    window.addEventListener('message', @snapshot_updater, false)
    @update_display()

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
      hidden = $("[name='embeddable_image_question_answer[image_url]']")
      hidden.val(@current_src)
      @$done_button.parents('form:first').submit()
      @hide()
      @save()

    @$delete_button.click =>
      @delete_image()

    @$reset_button.click =>
      @reset_image()

  update_display: ->
    $('#snpashot_thumbnail').show()
    $('#take_snapshot').html('replace snapshot')
    $('#snpashot_thumbnail').attr('src',@current_src)
    $('#snpashot_thumbnail').hide() unless @current_src
    $('#take_snapshot').html('take snapshot') unless @current_src

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

  set_image:(html) ->
    $value = $(html)
    @last_src = @current_src
    @current_src = $value.attr('src')
    $('#snapshot_image').attr('src',@current_src)
    @update_display()

  reset_image:()->
    if(@last_src)
      tmp = @current_src
      @current_src = @last_src
      @last_src = tmp
      $('#snapshot_image').attr('src',@current_src)
    @update_display()

  delete_image:() ->
    @last_src = @current_src
    @current_src = null
    $('#snapshot_image').attr('src',"missing")
    @update_display()

  snapshot_updater: (e) =>
    data = e.data
    if typeof(data) == 'string'
      data = JSON.parse(data)
    type = data.type
    if type == 'png'
      @set_image(data.values)

  hide: () ->
    @$content.dialog("close");

# export our class
window.ImageQuestion = image_question


#
# TODO: Right now this is the handshake for the lab frameworks
# parent window messaging API.  We don't need to follow this
# we could create our own API for shutterbug which would be simpler.
#
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

window.addEventListener('message', hello_handler, false)
