class ImageQuestionDrawingTool
  DRAWING_TOOL_OPTIONS = {
    width: 600,
    height: 600,
    stamps: {
      'Molecules': [
        'https://interactions-resources.concord.org/stamps/simple-atom.svg'
        'https://interactions-resources.concord.org/stamps/diatomic.svg'
        'https://interactions-resources.concord.org/stamps/diatomic-red.svg'
        'https://interactions-resources.concord.org/stamps/triatomic.svg'
        'https://interactions-resources.concord.org/stamps/positive-charge-symbol.svg'
        'https://interactions-resources.concord.org/stamps/negative-charge-symbol.svg'
        'https://interactions-resources.concord.org/stamps/positive-atom.svg'
        'https://interactions-resources.concord.org/stamps/negative-atom.svg'
        'https://interactions-resources.concord.org/stamps/slow-particle.svg'
        'https://interactions-resources.concord.org/stamps/medium-particle.svg'
        'https://interactions-resources.concord.org/stamps/fast-particle.svg'
        'https://interactions-resources.concord.org/stamps/low-density-particles.svg'
      ]
    },
    # LARA provides simple proxy (/image-proxy?url=). It's useful even if we use
    # only CORS enabled images, as not all browsers support CORS images (and our
    # own proxy ensures that the domain is the same).
    proxy: (url) ->
      return url if not proxy_image
      # "Free" URI parser in JS.
      parser = document.createElement('a')
      parser.href = url
      # Note that <a> element will set .hostname to correct value if we provide
      # relative path like '/resources/image.jgp'.
      return '/image-proxy?url=' + url if parser.hostname != window.location.hostname
      return url
  }

  proxy_image = true
  without_proxying_image = (cb) ->
    proxy_image = false
    cb()
    proxy_image = true

  DRAWING_TOOL_INITIAL_STATE = {
    strokeWidth: 4
  }

  constructor: (@image_question_id, @interactive_id = null)->
    # Selectors:
    @form_sel         = "#image_question_main_form_#{@image_question_id} form"
    @dialog_sel       = "#image_question_dialog_#{@image_question_id}"
    @drawing_tool_sel = "#drawing-tool-container_for_#{@image_question_id}"
    @interactive_sel  = "#interactive_#{@interactive_id}"

    # DOM entities:
    @$content = $(@dialog_sel)
    @popup = LARA.addPopup({
      content: @$content,
      closeButton: false,
      autoOpen: false,
      removeOnClose: false,
      width: 950,
      title: "Snapshot",
      modal: true,
      onOpen: =>
        @drawing_tool.calcOffset()
      onDragStop: =>
        @drawing_tool.calcOffset()
      onResize: =>
        @drawing_tool.calcOffset()
    })

    @$snapshot_button           = $("#{@form_sel} .take_snapshot")
    @$replace_button            = $("#{@form_sel} .replace_snapshot")
    @$drawing_button            = $("#{@form_sel} .drawing_button")
    @$upload_button             = $("#{@form_sel} .upload_button")
    @$edit_button               = $("#{@form_sel} .edit_answer")
    @$done_button               = $("#{@dialog_sel} .image_done_button")
    @$cancel_button             = $("#{@dialog_sel} .image_cancel_button")

    @$thumbnail                 = $("#{@form_sel} .snapshot_thumbnail")
    @$displayed_answer          = $("#{@form_sel} .answer_text")

    @$dialog_answer             = $("#{@dialog_sel} textarea.answer")

    @form_prefix                = "embeddable_image_question_answer"
    @form_id                    = "#{@form_prefix}_#{@image_question_id}"
    @$main_form                 = $("#{@form_sel}")
    @$image_url_field           = $("#{@form_sel} [name=\"#{@form_prefix}[image_url]\"]")
    @$annotated_image_url_field = $("#{@form_sel} [name=\"#{@form_prefix}[annotated_image_url]\"]")
    @$annotation_field          = $("#{@form_sel} [name=\"#{@form_prefix}[annotation]\"]")
    @$answer_text_field         = $("#{@form_sel} [name=\"#{@form_prefix}[answer_text]\"]")

    @drawing_tool = new DrawingTool(@drawing_tool_sel, DRAWING_TOOL_OPTIONS, DRAWING_TOOL_INITIAL_STATE)

    @save_indicator = SaveIndicator.instance()
    @page_lock_id = null

    # See: https://www.pivotaltracker.com/story/show/77973722
    @drawing_tool.setStrokeColor('#e66665') if @is_snapshot_question()

    @create_hooks()
    @update_display()

  get_current_thumbnail: ->
    @$annotated_image_url_field.val() || @$image_url_field.val()

  create_hooks: ->
    @$snapshot_button.click =>
      if @take_interactive_snapshot()
        startWaiting t('PLEASE_WAIT_TAKING_SNAPSHOT')
        @show_dialog()

    @$drawing_button.click =>
      # Same as snapshot, but without taking the snapshot.
      @set_drawing_tool_background()
      @show_dialog()

    @$upload_button.click =>
      @show_upload_dialog()

    @$replace_button.click =>
      @drawing_tool.clear(true)
      if @take_interactive_snapshot()
        startWaiting t('PLEASE_WAIT_TAKING_SNAPSHOT')
        @show_dialog()

    @$edit_button.click =>
      return if !@is_annotation_data_correct()
      @load_annotation()
      @show_dialog()

    @$cancel_button.click =>
      @load_annotation()
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
        @save_indicator.showSaved()
        @set_dialog_buttons_enabled(true)
        stopWaiting()
      ).on('ajax:error', (e, xhr, status, error) =>
        @save_indicator.showSaveFailed()
        @set_dialog_buttons_enabled(true)
        stopWaiting()
      )

  shutterbug_fail_hander: (message) ->
    LARA.addPopup({
      content: $("<div class='dialog-error'>#{message}</div>")[0]
      title: "Network error",
      modal: true,
      titlebarColor: '#2f70b0',
      width: 500
    })
    stopWaiting()
    @save_indicator.showSaveFailed()
    @set_dialog_buttons_enabled(true)

  take_interactive_snapshot: ->
    unless @interactive_id
      alert t('MISSING_INTERACTIVE')
      return false # snapshot request failed

    Shutterbug.snapshot
      selector: @interactive_sel
      server: gon.shutterbugURI
      done: (image_src) =>
        @set_image_source(image_src)
        stopWaiting()
      fail: (jqXHR, textStatus, errorThrown) =>
        @shutterbug_fail_hander(t('SNAPSHOT_FAILED'))
        stopWaiting()
        @set_dialog_buttons_enabled(true)
        @hide_dialog()
    true # snapshot request succeeded

  take_drawing_tool_snapshot: ->
    Shutterbug.snapshot
      selector: "#{@drawing_tool_sel} canvas.lower-canvas"
      server: gon.shutterbugURI
      done: (image_src) =>
        @copy_to_form_and_save(image_src)
        stopWaiting()
      fail: (jqXHR, textStatus, errorThrown) =>
        @shutterbug_fail_hander(t('DRAWING_SAVE_ERROR'))
        stopWaiting()
        @set_dialog_buttons_enabled(true)

  has_image_content: ->
    # This is a shutterbug question, so it's answered if there's a thumbnail
    return true if (@$snapshot_button.length > 0) && (@$annotation_field.val() or @get_current_thumbnail())
    # This is a drawing question, so an annotation is needed for it to be answered
    return true if (@$drawing_button.length > 0) && @$annotation_field.val()
    return true if (@$upload_button.length > 0) && @$annotation_field.val()
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

  set_drawing_tool_background: (bg_src = null)->
    bg_src = bg_src or @$image_url_field.val()
    # Sometimes background image can be undefined, e.g. for plain image questions.
    return unless bg_src
    @drawing_tool.setBackgroundImage(bg_src, 'shrinkBackgroundToCanvas', =>
      # Don't let users undo background setting.
      @drawing_tool.resetHistory()
    )

  start_saving: ->
    @save_indicator.showSaving()
    @set_dialog_buttons_enabled(false)
    startWaiting t('PLEASE_WAIT_SAVING_DRAWING')
    # Clear selection so it's not visible on the screenshot.
    @drawing_tool.clearSelection()
    # First part of saving is to get Shutterbug snapshot.
    @take_drawing_tool_snapshot()

  copy_to_form_and_save: (snapshot_src) ->
    # Second part of the save is to copy all the data from dialog to main form and submit it.
    @$annotated_image_url_field.val(snapshot_src)
    @$annotation_field.val(@drawing_tool.save())
    @$answer_text_field.val(@$dialog_answer.val())
    @$main_form.submit()

  show_dialog: ->
    @popup.open()
    # Always reset history (undo / redo) when user opens a dialog, as it may be confusing otherwise.
    @drawing_tool.resetHistory()
    # Lock page as soon as the user opens drawing tool.
    @page_lock_id = lockPageUnload() if @page_lock_id == null

  hide_dialog: () ->
    @popup.close()
    # Unlock page when dialog is closed.
    # Note that when user clicks "Save", we hide dialog only when question is successfuly saved.
    if @page_lock_id != null
      # See: page-unload-warning.coffee
      unlockPageUnload(@page_lock_id)
      @page_lock_id = null

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

  load_annotation: () ->
    @drawing_tool.load(@$annotation_field.val(), =>
      @drawing_tool.resetHistory()
    )

  is_snapshot_question: () ->
   @$snapshot_button.length > 0

  is_annotation_data_correct: () ->
    reset_annotation_data = =>
      if confirm t('OLD_DRAWING_FORMAT')
        @$annotation_field.val("")
        # We have to manually set background again. Note that we don't have to take
        # snapshot again, as it should be already available as image_url field in form.
        @set_drawing_tool_background()
        return true
      return false

    serialized_data = @$annotation_field.val()
    # TODO: it would be better to implement this validation in Drawing Tool itself.
    # Empty string is correct.
    return true if serialized_data.length == 0
    # Drawing Tool expects JSON object.
    try
      data = JSON.parse(serialized_data)
    catch error
      # Probably it's base64-encoded SVG Edit image. We can't load it into Drawing Tool.
      return reset_annotation_data()
    # Simple check if JSON contains two main properties specific for Drawing Tool data - 'canvas' and 'dt'.
    return true if data.dt? && data.canvas?
    # Unknown format.
    return reset_annotation_data()

  clear_dialog_answer: ()->
    if @$dialog_answer.val() != @$displayed_answer.data('raw')
      @$dialog_answer.val(@$displayed_answer.data('raw'))

  show_upload_dialog: ->
    $file = $("<input type='file'>")
    $file.on 'change', (e) =>
      file = $file[0].files?[0]
      @upload_file file if file
      false
    $drop = $("<div style='margin-bottom: 10px; width: 100%; height: 200px; background-color: #ddd'><div style='padding-top: 25%; text-align: center'>Drop an image here or click the button below to choose an image</div></div>")
    $drop.on 'dragover', false
    $drop.on 'dragenter', false
    $drop.on 'drop', (e) =>
      file = e.originalEvent?.dataTransfer?.files?[0]
      if file
        @upload_file file
      else
        items = e.originalEvent?.dataTransfer?.items
        for item in items
          if item.kind is 'string' and item.type.match(/^text\/uri-list/)
            item.getAsString (src) =>
              @set_uploaded_src src, true
            break
      false
    $container = $("<div>").append($drop).append($file)
    $html = $("<div>").append $container
    @uploadPopup = LARA.addPopup({
      content: $html[0],
      title: "Upload Image"
      modal: true
      width: 300
    })

  upload_error: (message, show_dialog_on_close) ->
    $content = $("<div style='padding: 20px; text-align: center'>")
    $content.html(message)
    LARA.addPopup
      content: $content[0]
      title: "Upload Image Error"
      modal: true
      width: 500
      onClose: => if show_dialog_on_close then @show_upload_dialog()
    false

  upload_file: (file) ->

    [major, minor] = file.type.split '/'
    if major isnt 'image'
      return @upload_error 'Sorry, you can only upload images', true
    if not window.FileReader
      return @upload_error 'Sorry, your browser does not support reading local files', false

    reader = new FileReader()
    reader.onload = =>
      @set_uploaded_src reader.result, false
    reader.onerror = =>
      @upload_error reader.error.message, true
    reader.readAsDataURL(file)

  set_uploaded_src: (src, use_proxy) ->
    loaded = =>
      @uploadPopup.close()
      @drawing_tool.clear(true)
      @show_dialog()
      if use_proxy
        @set_drawing_tool_background(src)
      else
        without_proxying_image => @set_drawing_tool_background(src)
      @update_display()
    errored = =>
      @upload_error "Sorry, the image you selected could not be loaded#{if use_proxy then " through our proxy" else ""}", true
    $img = $("<img>").on("error", errored).on("load", loaded)
    proxied_src = if use_proxy then DRAWING_TOOL_OPTIONS.proxy(src) else src
    $img.attr("src", proxied_src)


# export our class
window.ImageQuestionDrawingTool = ImageQuestionDrawingTool
