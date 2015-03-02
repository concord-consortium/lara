# displays a modal JQuery UI dialog
modalDialog = (correct, feedback) ->
  if correct
    title        = "Correct"
    dialogClass  = "correct"
    feedback   ||= "Yes! You are correct."
  else
    title        = "Alert"
    dialogClass  = "incorrect"
    feedback   ||= "Sorry, that is incorrect."

  $('#modal-dialog').html "<div class='check-answer'><p class='response'>#{feedback}</p></div"

  # dialog is from jquery UI
  $('#modal-dialog').dialog(title: title, modal: true, dialogClass: dialogClass)

# export
window.modalDialog = modalDialog