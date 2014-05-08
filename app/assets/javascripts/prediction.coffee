class Prediction

  constructor: (@$button) ->
    @$form = @$button.parent().parent()
    @$is_final = @$form.find('.hidden_is_final')
    if @marked_final()
      @disable_form()
    else
      @enable_form()

    @$button.click (e) =>
      @record_answer()
      @disable_form()

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

window.Prediction = Prediction
$(document).ready ->
  Prediction.saver = window.SaveOnChangePage.instance
  $('.prediction_button').each (i,$pred) ->
    p = new Prediction($($pred))
