
scheduled_jobs     = {}
update_interval_s  = 0.6
saveTimer          = null

showSaveFailed = ->
  $("#save").removeClass("pending")
  $("#save").addClass("error")
  $("#save").html("Save failed!")

showSaved  = ->
  # Wait a few seconds before actually running
  saveTimer = setTimeout ->
    $("#save").removeClass("error")
    $("#save").removeClass("pending")
    $("#save").html("Saved.")
    # Fade out.
    $("#save").animate({'opacity': '0'}, 'slow')
  , 2000

showSaving = ->
  $("#save").removeClass("error")
  $("#save").addClass("pending")
  $("#save").html("Saving...")
  $("#save").css({'opacity': '0.5'})
  $("#save").animate({'opacity': '1.0'}, 'fast')

saveElement = (elem) ->
    showSaving()
    $(elem).parents('form:first').submit()
    # We should be evaluating the response to that and calling either showSaved() or saveFailed().


# remove events scheduled for elem
unschedule = (elem) ->
  job = scheduled_jobs[elem]
  clearTimeout job if job
  scheduled_jobs[elem] = null

schedule = (elem) ->
  unschedule elem # remove any existing events
  action = ->
    saveElement(elem)

  scheduled_jobs[elem] = setTimeout action, update_interval_s * 1000


$(document).ready ->
  $("#save").removeClass('error')
  $("#save").css('opacity',0)
  $(document).ajaxSuccess (e) =>
    showSaved()
  $(document).ajaxError (e) =>
    showSaveFailed()

  # Fire inputs field changes on 'change' events with no scheduled_jobs
  $('.live_submit').on 'change', (e) ->
    saveElement(this)

  # Fire textarea changes on 'blur' events
  $('textarea.live-submit').on 'blur', (e) ->
    saveElement(this)

  # Qeue textarea changes on 'keyup' events
  $('textarea.live-submit').on 'keyup', (e) ->
    schedule(this)