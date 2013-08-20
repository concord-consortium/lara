class image_question
  constructor: (@image_question_id="blank")->
    @image_url=""
    @form_sel   = "#image_question_answer_form_#{@image_question_id}"
    @svg_canvas_id = "image_question_annotation_for_#{@image_question_id}"
    @$annotation_field = $("##{@svg_canvas_id}")
    @button_sel = "#image_question_#{@image_question_id}"
    @sb_svg_src = "#sb_svg_src_#{@image_question_id}"
    @$sb_svg_src = $(@sb_svg_src)
    @svg_annotation_data = ""
    @$content  = $(@form_sel)
    @interactive_selector = ".interactive-mod > *:first-child"

    @last_svg = null
    @$content.dialog({
      autoOpen: false,
      width: 800,
      title: "Snapshot",
      modal: true,
      open: =>
        # re-check browser features and update unit calculations
        canv = @get_svg_canvas()
        if (canv && canv.recheckBrowserFeatures)
          canv.recheckBrowserFeatures()
    })

    @shutterbug       = new Shutterbug(@interactive_selector, null,(image_tag)=>
      @set_image(image_tag)
    ,@image_question_id)

    @shutterbug_svg  = new Shutterbug(@sb_svg_src, null,(image_tag)=>
      @set_svg_input(image_tag)
      @submit_svg_form()
      @$sb_svg_src.empty().hide()
    ,"svg_" + @image_question_id)

    @$snapshot_button = $("#{@button_sel} .take_snapshot")
    @$edit_button     = $("#{@button_sel} .edit_answer")
    @$done_button     = $("#{@form_sel} .image_done_button")
    @$svg_form        = $("#{@form_sel} form")

    @$delete_button   = $("#{@form_sel} .image_delete_button")
    @$retake_button   = $("#{@form_sel} .retake_snapshot")
    @$undo_button     = $("#{@form_sel} .image_reset_button")

    @$thumbnail        =$("#{@button_sel} .snapshot_thumbnail")
    @$displayed_answer =$("#{@button_sel} .answer_text")

    @create_hooks()
    @$current_src_field = $("#{@form_sel} [name=\"embeddable_image_question_answer[image_url]\"]")
    @current_src = @$current_src_field.val()
    @current_thumbnail = $("#{@form_sel} [name=\"embeddable_image_question_answer[annotated_image_url]\"]").val()
    @update_display()

  create_hooks: ->
    @$snapshot_button.click =>
      @shutterbug.getDomSnapshot()
      @show()

    @$retake_button.click =>
      @shutterbug.getDomSnapshot()

    @$edit_button.click =>
      @show()
      @set_svg_background()


    @$done_button.click =>
      @get_svg_canvas().getSvgString() (data, error) =>
        @svg_annotation_data = data
        $svg = $(data)

        @$sb_svg_src.show();
        w = $svg.attr('width')
        h = $svg.attr('height')

        @$sb_svg_src.css('width',w)
        @$sb_svg_src.css('height',h)
        @$sb_svg_src.css('background-image',  "url(#{@current_src})")

        @$sb_svg_src.css('background-size', "#{w}px #{h}px")
        @$sb_svg_src.html(data)
        @shutterbug_svg.getDomSnapshot()
        @hide()
        @save()

    @$delete_button.click =>
      @delete_image()

    @$undo_button.click =>
      @reset_image()

    @$svg_form.on('ajax:success', (e, data, status, xhr) =>
      # update at least the answer perhaps the thumbnail
      # we might also want to delay the closing the dialog until this happens
      @$displayed_answer.html(data.answer_html)
    ).bind 'ajax:error', (e, xhr, status, error) =>
      # don't update the answer and possibly revert the thumbnail if it was
      # updated
      # should show "<p>ERROR</p>" somewhere
      # if the form is still open it would make sense to put the error there

  update_display: ->
    @$thumbnail.show()
    @$thumbnail.attr("src", @current_thumbnail)
    @$thumbnail.hide()
    if @current_thumbnail
      @$thumbnail.show()

    @$snapshot_button.show()
    @$edit_button.hide()

    if @current_src
      @$edit_button.show()
      @$snapshot_button.hide()

    if @undo_button
      @undo_button.hide()
    if @last_src
      @$undo_button.show()
    @set_svg_background()

  get_svg_canvas: =>
    svgCanvas["#{@svg_canvas_id}"]

  set_svg_background: =>
    canv = @get_svg_canvas()
    if (canv && canv.setBackground)
      canv.setBackground('#FFF', @current_src)()

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


  save: ->
      @show_saving()
      # TODO: validate response and calling showSaved() or saveFailed().
      @show_saved();

  show: ->
    @$content.dialog("open");

  set_image_source: (src) ->
    @last_src = @current_src
    @current_src = src
    @$current_src_field.val(src)
    @update_display()

  set_image:(html) ->
    @set_image_source($(html).attr("src"))

  set_svg_input:(html) =>
    $value= $(html)
    $src = $value.attr("src")
    hidden = $("#{@form_sel} [name=\"embeddable_image_question_answer[annotated_image_url]\"]")
    hidden.val($src)
    @current_thumbnail = $src
    @update_display()

  submit_svg_form: ->
    $input = $("##{@svg_canvas_id}")
    $input.attr("value", sketchily_encode64("<?xml version=\"1.0\"?>\n" + @svg_annotation_data))
    hidden = $("#{@form_sel} [name=\"embeddable_image_question_answer[image_url]\"]")
    hidden.val(@current_src)
    @$svg_form.submit()

  reset_image:()->
    if(@last_src)
      @set_image_source(@last_src)

    if(@last_svg)
      @get_svg_canvas().setSvgString(@last_svg)()


  delete_image:() ->
    @get_svg_canvas().getSvgString() (data,error) =>
      @last_svg = data
    @get_svg_canvas().clear()()
    @$annotation_field.attr('value',"")
    @set_image_source("")


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
