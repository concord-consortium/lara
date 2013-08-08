origin = () ->
  document.location.href.match(/(.*?\/\/.*?)\//)[1]

class image_question
  constructor: (@image_question_id="blank")->
    @prompt="why do you think..."
    @answer="because ..."
    @image_url=""
    @form_sel   = "#image_question_answer_form_#{@image_question_id}"
    @svg_canvas_id = "image_question_annotation_for_#{@image_question_id}"
    @button_sel = "#image_question_#{@image_question_id}"
    @$content  = $(@form_sel)

    @$content.dialog({
      autoOpen: false,
      width: 800,
      title: "Snapshot",
      modal: true
    })

    @shutterbug       = new Shutterbug(".interactive-mod > *:first-child", null,(image_tag)=>
      @set_image(image_tag)
      @set_svg_background()
    ,@image_question_id)

    @$answer_text     = $("#{@form_sel} .image_answer_text")

    @$snapshot_button = $("#{@button_sel} .take_snapshot")
    @$edit_button     = $("#{@button_sel} .edit_answer")
    @$done_button     = $("#{@form_sel} .image_done_button")

    @$delete_button   = $("#{@form_sel} .image_delete_button")
    @$redo_button     = $("#{@form_sel} .image_redo_button")
    @$reset_button    = $("#{@form_sel} .image_reset_button")
    @$cancel_button   = $("#{@form_sel} .image_cancel_button")

    @create_hooks()
    @current_src = $("#{@form_sel} [name=\"embeddable_image_question_answer[image_url]\"]").val()
    @update_display()

  create_hooks: ->
    @$snapshot_button.click =>
      @shutterbug.getDomSnapshot()
      @show()

    @$edit_button.click =>
      @set_svg_background()
      @show()

    @$cancel_button.click =>
      @cancel()


    @$done_button.click =>
      @get_svg_canvas().getSvgString() (data, error) =>
        $input = $("##{@svg_canvas_id}")
        $input.attr("value", sketchily_encode64("<?xml version=\"1.0\"?>\n" + data));
        hidden = $("#{@form_sel} [name=\"embeddable_image_question_answer[image_url]\"]")
        hidden.val(@current_src)
        @$done_button.parents("form:first").submit()
        @hide()
        @save()

    @$delete_button.click =>
      @delete_image()

    @$reset_button.click =>
      @reset_image()

  update_display: ->
    $("#{@button_sel} .snapshot_thumbnail").show()
    $("#{@button_sel} .take_snapshot_label").html("replace snapshot")
    $("#{@button_sel} .snapshot_thumbnail").attr("src",@current_src)
    $("#{@button_sel} .snapshot_thumbnail").hide() unless @current_src
    $("#{@button_sel} .take_snapshot_label").html("take snapshot") unless @current_src

  get_svg_canvas: =>
    svgCanvas["#{@svg_canvas_id}"]

  set_svg_background: =>
    @get_svg_canvas().setBackground('#FFF', @current_src)(@set_svg_background_cb)

  save_failed: ->
    $("#save").html("Save failed!")

  show_saved: ->
    @saveTimer = setTimeout ->
      $("#save").html("Saved.")
      # Fade out.
      $("#save").animate({"opacity": "0"}, "slow")
    , 1000

  show_saving: ->
    $("#save").html("Saving...")
    $("#save").animate({"opacity": "1.0"}, "fast")

  cancel: ->
    @hide()

  save: ->
      @show_saving()

      # $(elem).parents("form:first").submit()
      # We should be evaluating the response to that and calling either showSaved() or saveFailed().
      @show_saved();

  show: ->
    @$content.dialog("open");

  set_image:(html) ->
    $value = $(html)
    @last_src = @current_src
    @current_src = $value.attr("src")
    $("#{@form_sel} .snapshot_image").attr("src",@current_src)
    @update_display()

  reset_image:()->
    if(@last_src)
      tmp = @current_src
      @current_src = @last_src
      @last_src = tmp
      $("#{@form_sel} .snapshot_image").attr("src",@current_src)
    @update_display()

  delete_image:() ->
    @last_src = @current_src
    @current_src = null
    $("#{@form_sel} .snapshot_image").attr("src","missing")
    @update_display()

  snapshot_updater: (e) =>
    data = e.data
    if typeof(data) == "string"
      data = JSON.parse(data)
    type = data.type
    if type == "png"
      @set_image(data.values)

  hide: () ->
    @$content.dialog("close");

# export our class
window.ImageQuestion = image_question
