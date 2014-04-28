class Prediction

  constructor: (@$button) ->
    @$form = @$button.parent()
    @$is_final = @$form.find('.hidden_is_final')
    @$button.click (e) =>
      @$is_final.val('1')
      window.SaveOnChangePage.instance.force_save_item(@$form)
      @toggle()

  toggle: ->
    @$form.find(':input').prop("disabled", true);
    @$form.find('.prediction_button').hide() 
    @$form.find('.answer_is_final').show() 
window.Prediction = Prediction
$(document).ready ->
  $('.prediction_button').each (i,$pred) ->
    p = new Prediction($($pred))
