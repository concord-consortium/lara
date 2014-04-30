class Prediction

  constructor: (@$button) ->
    @$form = @$button.parent().parent()
    @$is_final = @$form.find('.hidden_is_final')
    if @$is_final.val() == "t"
      @disable_form()
    else
      @enable_form()

    @$button.click (e) =>
      @record_answer()
      @disable_form()

  record_answer: ->
    @$is_final.val('1')
    Prediction.saver.force_save_item(@$form)

  enable_form: ->
    @$form.find(':input').prop("disabled", false);
    @$form.find('.still_answering').show()
    @$form.find('.is_final').hide()

  disable_form: ->
    @$form.find(':input').prop("disabled", true);
    @$form.find('.still_answering').hide()
    @$form.find('.is_final').show()

window.Prediction = Prediction
$(document).ready ->
  Prediction.saver = window.SaveOnChangePage.instance
  $('.prediction_button').each (i,$pred) ->
    p = new Prediction($($pred))
