class ImageQuestion
  constructor: (@image_question_id="blank")->
    # Initial default values
    @image_url            = ""
    @svg_annotation_data  = ""
    @last_svg             = null

    # Constant selectors:
    @form_prefix          = "embeddable_image_question_answer"
    @dialog_sel           = "#image_question_answer_form_#{@image_question_id}"
    @svg_canvas_id        = "image_question_annotation_for_#{@image_question_id}"
    @form_sel             = "#image_question_#{@image_question_id}"
    @sb_svg_src           = "#sb_svg_src_#{@image_question_id}"
    @interactive_selector = ".interactive-mod > *:first-child"

    # Select the dom entities...
    @$annotation_field    = $("#sketchily_#{@svg_canvas_id}")
    @$sb_svg_src          = $(@sb_svg_src)
    @$content             = $(@dialog_sel)

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

    @$snapshot_button           = $("#{@form_sel} .take_snapshot")
    @$edit_button               = $("#{@form_sel} .edit_answer")
    @$done_button               = $("#{@dialog_sel} .image_done_button")
    @$cancel_button             = $("#{@dialog_sel} .image_cancel_button")
    @$svg_form                  = $("#{@dialog_sel} form")

    @$delete_button             = $("#{@dialog_sel} .image_delete_button")
    @$replace_button            = $("#{@form_sel} .replace_snapshot")
    @$undo_button               = $("#{@dialog_sel} .image_reset_button")

    @$saved_response            = $("#{@form_sel} .answer_text")
    @$text_response             = $("#{@dialog_sel} .text_response textarea")

    @$drawing_button            = $("#{@form_sel} .drawing_button")

    @$thumbnail                 = $("#{@form_sel} .snapshot_thumbnail")
    @$displayed_answer          = $("#{@form_sel} .answer_text")

    @$image_url_field           = $("#{@form_sel} [name=\"#{@form_prefix}[image_url]\"]")
    @$annotated_image_url_field = $("#{@form_sel} [name=\"#{@form_prefix}[annotated_image_url]\"]")


    @current_thumbnail  = @get_current_thumbnail()

    @current_src        = @$image_url_field.val()
    @create_snapshot_shutterbug()
    @create_svg_shutterbug()
    @create_hooks()
    @update_display()

  get_current_thumbnail: ->
    @$annotated_image_url_field.val() ||  @$image_url_field.val()

  create_hooks: ->
    @$snapshot_button.click =>
      @last_svg = ' '
      @shutterbug.getDomSnapshot()
      @show()

    @$drawing_button.click =>
      # Same as snapshot, but without taking the snapshot.
      @last_svg = ' '
      @set_svg_background()
      @show()

    @$replace_button.click =>
      @replace_snapshot()

    @$edit_button.click =>
      # Save @last_svg so cancel will work
      @last_svg = sketchily_decode64(@$annotation_field.val())
      @show()
      @set_svg_background()

    @$cancel_button.click =>
      @last_svg = ' ' unless @last_svg
      @reset_image()
      @clear_text_response()
      @hide()

    @$done_button.click =>
      @save()

    @$undo_button.click =>
      @reset_image()

    @$svg_form.on('ajax:success', (e, data, status, xhr) =>
      # update at least the answer perhaps the thumbnail
      # we might also want to delay the closing the dialog until this happens
      @$displayed_answer.html(data.answer_html)
    ).bind 'ajax:error', (e, xhr, status, error) =>
      # don't update the answer and possibly revert the thumbnail 
      # should show "<p>ERROR</p>" somewhere
      # if the form is still open it would make sense to put the error there

  clear_drawing_layer: -> 
    svg = @get_svg_canvas()
    svg.deleteCurrentLayer() () ->
      svg.renameCurrentLayer("old") () ->
        svg.createLayer("new") () ->
          svg.setCurrentLayer("old") () ->
            svg.deleteCurrentLayer() () ->
              svg.setCurrentLayer("new")()
  create_snapshot_shutterbug: ->
    @shutterbug       = new Shutterbug(@interactive_selector, null,(image_tag)=>
      @set_image(image_tag)
      @clear_drawing_layer()
    ,@image_question_id)

  create_svg_shutterbug: ->
    @shutterbug_svg  = new Shutterbug(@sb_svg_src, null,(image_tag)=>
      @set_svg_input(image_tag)
      @submit_svg_form()
      @$sb_svg_src.empty().hide()
      @copy_annotation_to_live_submit("annotation")
      @copy_annotation_to_live_submit("answer_text")
      @hide()
      # TODO: validate response and calling showSaved() or saveFailed().
      @show_saved()
      LoggerUtils.submittedQuestionLogging(@image_question_id)
    ,"svg_" + @image_question_id)

  has_image_content: ->
    # This is a shutterbug question, so it's answered if there's a thumbnail
    if (@$snapshot_button.length > 0) and (@current_src or @current_thumbnail)
      @show_edit_buttons()
      return true

    # This is a drawing question, so an annotation is needed for it to be answered
    if (@$drawing_button.length > 0) and (@current_annotation or @annotated_url or @current_thumbnail)
      @show_edit_buttons()
      return true
    return false

  update_display: ->
    @annotated_url = @$annotation_field.val()
    @current_thumbnail = @get_current_thumbnail()
    @current_annotation = $("#image_question_annotation_for_#{@image_question_id}").val()
    @$thumbnail.show()
    @$thumbnail.attr("src", @current_thumbnail)
    @$thumbnail.hide()
    if @current_thumbnail
      @$thumbnail.show()

    @$snapshot_button.show()
    @$replace_button.hide()
    @$edit_button.hide()

    if @has_image_content()
      @show_edit_buttons()

    @set_svg_background()

  show_edit_buttons: =>
    @$edit_button.show()
    @$replace_button.show()
    @$drawing_button.hide()
    @$snapshot_button.hide()

  get_svg_canvas: ->
    svgCanvas["#{@svg_canvas_id}"]

  set_svg_background: ->
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
    @get_svg_canvas().getSvgString() (data, error) =>
      @svg_annotation_data = data
      $svg = $(data)
      @$sb_svg_src.show();
      w = $svg.attr('width')
      h = $svg.attr('height')

      @$sb_svg_src.css('width',w)
      @$sb_svg_src.css('height',h)
      @$sb_svg_src.css('background-image',  "url(#{@current_src})")
      @$sb_svg_src.css('background-repeat',  "no-repeat")
      @$sb_svg_src.css('background-position',  "center")
      @$sb_svg_src.css('background-size',  "contain")
      @$sb_svg_src.css('background-color',  "#ffffff")
      @$sb_svg_src.html(data)
      @shutterbug_svg.getDomSnapshot()


  copy_annotation_to_live_submit: (name) ->
    field_name   = """ [name="#{@form_prefix}[#{name}]"] """
    live_field   = $("#{@form_sel} #{field_name}")
    dialog_field = $("#{@dialog_sel} #{field_name}")

    dialog_value = dialog_field.val()
    live_field.val(dialog_value)
    live_field.trigger("change")

  show: ->
    @$content.dialog("open")

  set_image_source: (src) ->
    @last_src = @current_src unless @current_src == ""
    @current_src = src
    @$image_url_field.val(src)
    @update_display()

  set_image:(html) ->
    @set_image_source($(html).attr("src"))

  set_svg_input:(html) =>
    $value= $(html)
    $src = $value.attr("src")
    @$annotated_image_url_field.val($src)
    @current_thumbnail = $src
    @update_display()

  submit_svg_form: ->
    $input = @$annotation_field
    $input.attr("value", sketchily_encode64("<?xml version=\"1.0\"?>\n" + @svg_annotation_data))
    hidden = $("#{@form_sel} [name=\"#{@form_prefix}[image_url]\"]")
    hidden.val(@current_src)
    @$svg_form.submit()

  reset_image:()->
    if(@last_src)
      @set_image_source(@last_src)

    if(@last_svg)
      @get_svg_canvas().setSvgString(@last_svg)()

  clear_text_response: ()->
    if @$text_response.val() != @$saved_response.data('raw')
      @$text_response.val(@$saved_response.data('raw'))

  replace_snapshot:() ->
    @shutterbug.getDomSnapshot()
    @show()
    @clear_drawing_layer()

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
window.ImageQuestion = ImageQuestion
