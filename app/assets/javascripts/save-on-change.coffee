
class SaveIndicator
  constructor: (@$elem=$("#save")) ->
    @saveTimer  = null
    @$elem      = $("#save")
    @clear()  # start hidden.

  clear: () ->
    @$elem.removeClass('error')
    @$elem.css('opacity',0)

  showSaveFailed: (message="Save failed!") ->
    @$elem.removeClass("pending")
    @$elem.addClass("error")
    @$elem.html(message)

  showSaved: (message="Saved.") ->
    # Wait a ½ second before actually displaying:
    @saveTimer = setTimeout =>
      @$elem.removeClass("error")
      @$elem.removeClass("pending")
      @$elem.html(message)
      @$elem.animate({'opacity': '0'}, 'slow') # Fade out.
    , 500

  showSaving: ->
    @$elem.removeClass("error")
    @$elem.addClass("pending")
    @$elem.html("Saving...")
    @$elem.css({'opacity': '0.5'})
    @$elem.animate({'opacity': '1.0'}, 'fast')


class SaveOnChange
  constructor: (@$elem) ->
    @scheduled_job      = null
    @previous_value     = null
    @update_interval_s  = 0.6
    @$form              = $(@$elem).parents('form:first')
    @save_indicator     = new SaveIndicator($("#save"))
    @setupEvents()

  setupEvents: ->
    # Fire inputs field changes on 'change' events with no scheduled_jobs
    @$elem.on 'change', (e) =>
      console.log("Freaking saw the event yo")
      @saveElement()
    @$elem.on 'blur', (e) =>
      @saveElement()
    @$elem.on 'keyup', (e) =>
      @schedule()

  saveElement: ->
      data = @$form.serialize()
      return if @previous_value == data
      @save_indicator.showSaving()
      $.ajax({
        type: "POST",
        url: @$form.attr( 'action' ),
        data: @$form.serialize(),
        success: (response) =>
          @previous_value = data
          @save_indicator.showSaved()
        error: (jqxhr, status, error) =>
          @save_indicator.showSaveFailed()
      })
      # unschedule elem

  # remove events scheduled for elem
  unschedule: () ->
    clearTimeout(@scheduled_job) if @scheduled_job
    @scheduled_job = null

  schedule:  () ->
    @unschedule() # remove any existing events
    action = () =>
      @saveElement()
    @scheduled_job = setTimeout(action, @update_interval_s * 1000)

$(document).ready ->
  window.SaveOnChange = SaveOnChange
  $('.live_submit').each (i,e) =>
    new SaveOnChange($(e))

