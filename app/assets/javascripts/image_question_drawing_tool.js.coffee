class ImageQuestionDrawingTool
  constructor: (@image_question_id="blank")->
    # Initial default values
    @image_url            = ""

    # Constant selectors:
    @form_sel              = "#image_question_main_form_#{@image_question_id} form"
    @dialog_sel            = "#image_question_dialog_#{@image_question_id}"
    @drawing_tool_selector = "#drawing-tool-container_for_#{@image_question_id}"
    @interactive_selector  = ".interactive-mod > *:first-child"

    # DOM entities:
    @$content = $(@dialog_sel)
    @$content.dialog({
      dialogClass: "no-close",
      autoOpen: false,
      width: 800,
      title: "Snapshot",
      modal: true,
      open: =>
        @drawing_tool.canvas.calcOffset()
      dragStop: =>
        @drawing_tool.canvas.calcOffset()
      resize: =>
        @drawing_tool.canvas.calcOffset()
    })

    @$snapshot_button           = $("#{@form_sel} .take_snapshot")
    @$replace_button            = $("#{@form_sel} .replace_snapshot")
    @$drawing_button            = $("#{@form_sel} .drawing_button")
    @$edit_button               = $("#{@form_sel} .edit_answer")
    @$done_button               = $("#{@dialog_sel} .image_done_button")
    @$cancel_button             = $("#{@dialog_sel} .image_cancel_button")

    @$thumbnail                 = $("#{@form_sel} .snapshot_thumbnail")
    @$displayed_answer          = $("#{@form_sel} .answer_text")

    @$dialog_answer             = $("#{@dialog_sel} textarea.answer")

    @form_prefix                = "embeddable_image_question_answer"
    @$main_form                 = $("#{@form_sel}")
    @$image_url_field           = $("#{@form_sel} [name=\"#{@form_prefix}[image_url]\"]")
    @$annotated_image_url_field = $("#{@form_sel} [name=\"#{@form_prefix}[annotated_image_url]\"]")
    @$annotation_field          = $("#{@form_sel} [name=\"#{@form_prefix}[annotation]\"]")
    @$answer_text_field         = $("#{@form_sel} [name=\"#{@form_prefix}[answer_text]\"]")

    @drawing_tool = new DrawingTool(@drawing_tool_selector, {width: 600, height: 450})
    @drawing_tool.load(@$annotation_field.val())
    @drawing_tool.resizeCanvasToBackground()

    @create_snapshot_shutterbug()
    @create_drawing_tool_shutterbug()
    @create_hooks()
    @update_display()

  get_current_thumbnail: ->
    @$annotated_image_url_field.val() || @$image_url_field.val()

  create_hooks: ->
    @$snapshot_button.click =>
      @shutterbug.getDomSnapshot()
      @show_dialog()

    @$drawing_button.click =>
      # Same as snapshot, but without taking the snapshot.
      @set_drawing_tool_background()
      @show_dialog()

    @$replace_button.click =>
      @drawing_tool.clear(true)
      @shutterbug.getDomSnapshot()
      @show_dialog()

    @$edit_button.click =>
      @show_dialog()

    @$cancel_button.click =>
      @reset_image()
      @clear_dialog_answer()
      @hide_dialog()

    @$done_button.click =>
      @start_saving()

    @$main_form
      .on('ajax:success', (e, data, status, xhr) =>
        # Successful save.
        @$displayed_answer.html(data.answer_html)
        @update_display()
        @hide_dialog()
        @show_saved()
        @set_dialog_buttons_enabled(true)
      ).on('ajax:error', (e, xhr, status, error) =>
        @save_failed()
        @set_dialog_buttons_enabled(true)
      )

  create_snapshot_shutterbug: ->
    @shutterbug = new Shutterbug(@interactive_selector, null, (image_tag) =>
      @set_image_source($(image_tag).attr("src"))
    , @image_question_id)

  create_drawing_tool_shutterbug: ->
    @shutterbug_drawing_tool = new Shutterbug("#{@drawing_tool_selector} .dt-canvas-container", null, (image_tag) =>
      @copy_to_form_and_save(image_tag)
    , "drawing_tool_" + @image_question_id)

  has_image_content: ->
    # This is a shutterbug question, so it's answered if there's a thumbnail
    if (@$snapshot_button.length > 0) && (@$annotation_field.val() or @get_current_thumbnail())
      return true
    # This is a drawing question, so an annotation is needed for it to be answered
    if (@$drawing_button.length > 0) && @$annotation_field.val()
      return true
    return false

  update_display: ->
    current_thumbnail = @get_current_thumbnail()
    @$thumbnail.attr("src", current_thumbnail)
    if current_thumbnail
      @$thumbnail.show()
    else
      @$thumbnail.hide()

    @$snapshot_button.show()
    @$replace_button.hide()
    @$edit_button.hide()

    if @has_image_content()
      @show_edit_buttons()

  show_edit_buttons: =>
    @$edit_button.show()
    @$replace_button.show()
    @$drawing_button.hide()
    @$snapshot_button.hide()

  set_drawing_tool_background: ->
    bg_src = @$image_url_field.val()
    # Sometimes background image can be undefined, e.g. for plain image questions.
    @drawing_tool.setBackgroundImage(bg_src, 'resizeCanvasToBackground') if bg_src

  show_saved: ->
    @saveTimer = setTimeout ->
      $("#save").html("Saved.")
      # Fade out.
      $("#save").animate({"opacity": "0"}, "slow")
    , 1000

  save_failed: ->
    $("#save").html("Save failed!")

  show_saving: ->
    $("#save").html("Saving...")
    $("#save").animate({"opacity": "1.0"}, "fast")

  start_saving: ->
    @show_saving()
    @set_dialog_buttons_enabled(false)
    # Clear selection so it's not visible on the screenshot.
    @drawing_tool.clearSelection()
    # First part of saving is to get Shutterbug snapshot.
    @shutterbug_drawing_tool.getDomSnapshot()

  copy_to_form_and_save: (snapshot_image_tag) ->
    # Second part of the save is to copy all the data from dialog to main form and submit it.
    @$annotated_image_url_field.val($(snapshot_image_tag).attr("src"))
    @$annotation_field.val(@drawing_tool.save())
    @$answer_text_field.val(@$dialog_answer.val())
    @$main_form.submit()

  show_dialog: ->
    @$content.dialog("open")

  hide_dialog: () ->
    @$content.dialog("close");

  set_dialog_buttons_enabled: (val) ->
    [@$done_button, @$cancel_button].forEach ($btn) =>
      if val
        $btn.removeClass("disabled")
      else
        $btn.addClass("disabled")
      $btn.prop("disabled", !val)

  set_image_source: (src) ->
    @$image_url_field.val(src)
    @set_drawing_tool_background()

  reset_image: ()->
    @drawing_tool.load(@$annotation_field.val())

  clear_dialog_answer: ()->
    if @$dialog_answer.val() != @$displayed_answer.data('raw')
      @$dialog_answer.val(@$displayed_answer.data('raw'))

# export our class
window.ImageQuestionDrawingTool = ImageQuestionDrawingTool
