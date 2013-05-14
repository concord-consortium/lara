# displays a modal JQuery UI dialog
modal = (correct, feedback) ->
  if correct
    title        = "Correct"
    dialogClass  = "correct"
    feedback   ||= "Yes! You are correct."
  else
    title        = "Incorrect"
    dialogClass  = "incorrect"
    feedback   ||= "Sorry, that is incorrect."

  $('#modal').html "<div class='check-answer'><p class='response'>#{feedback}</p></div"

  # dialog is from jquery UI
  $('#modal').dialog(title: title, modal: true, dialogClass: dialogClass)

# export
window.modal = modal