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

    @shutterbug       = new Shutterbug('iframe',null, (image_tag)=>
      @set_image(image_tag)
    );
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
      @shutterbug.getDomSnapshot()
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

