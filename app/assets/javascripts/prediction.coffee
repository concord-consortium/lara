class Prediction
  constructor: (@$button) ->
    @$form = @$button.parent().parent()
    @$is_final = @$form.find('.hidden_is_final')
    @register_listeners()
    if @marked_final()
      @disable_form()
    else
      @enable_form()

    @disable_submit_button()

  register_listeners: ->
    $(document).on "answer_for", (e,opts) =>
      if opts.source == @$form.attr('id')
        @enable_submit_button()
    $(document).on "no_answer_for", (e,opts) =>
      if opts.source == @$form.attr('id')
        @disable_submit_button()

  enable_submit_button: ->
    console.log "enabled button"
    @submit_enabled = true
    @$button.prop("disabled", false)
    @$button.removeClass("disabled")

  disable_submit_button: ->
    console.log "disabled button"
    @submit_enabled = false
    @$button.prop("disabled", true)
    @$button.addClass("disabled")

  marked_final: ->
    val = @$is_final.val()
    (val == "t" || val == "1")

  record_answer: ->
    @$is_final.val('1')
    Prediction.saver.force_save_item(@$form)

  enable_form: ->
    @$form.find(':input').prop("disabled", false)
    @$form.find('button').prop("disabled", false)
    @$form.find('button').removeClass("disabled")
    @$form.find('.still_answering').show()
    @$form.find('.is_final').hide()
    @disable_forward_navigation()

  disable_form: ->
    @$form.find(':input').prop("disabled", true)
    @$form.find('button').prop("disabled", true)
    @$form.find('button').addClass("disabled")
    @$form.find('.still_answering').hide()
    @$form.find('.is_final').slideDown()
    @enable_forward_navigation()

  disable_forward_navigation: ->
    $(document).trigger("prevent_forward_navigation",{source: @$form})

  enable_forward_navigation: ->
    $(document).trigger("enable_forward_navigation",{source: @$form})

  question_answered: =>

window.Prediction = Prediction
$(document).ready ->
  Prediction.saver = window.SaveOnChangePage.instance
  $('.prediction_button').each (i,$pred) ->
    p = new Prediction($($pred))
