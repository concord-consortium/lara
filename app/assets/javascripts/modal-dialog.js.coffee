# displays a modal JQuery UI dialog
modalDialog = (correct, feedback) ->
  if correct
    title         = "Correct"
    titlebarColor = "#75a643"
    feedback    ||= "Yes! You are correct."
  else
    title         = "Alert"
    titlebarColor = "#b45532"
    feedback    ||= "Sorry, that is incorrect."

  $content = $("<div class='check-answer'><p class='response'>#{feedback}</p></div")
  LARA.addPopup({
    content: $content,
    title,
    titlebarColor,
    modal: true
  })

# export
window.modalDialog = modalDialog
