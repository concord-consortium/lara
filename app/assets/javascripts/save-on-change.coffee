
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
  changeInterval: 200  # Fire change and blur events almost instantly.
  keyUpinterval:  2000 # Fire keyup events with a larger delay
  constructor: (@$form, @page) ->
    @scheduled_job      = null
    @previous_value     = null
    @setupEvents()

  setupEvents: ->

    @$form.find('input,textarea,select').on 'change blur', (e) =>
      @schedule(@changeInterval)
    @$form.find('input,textarea').on 'keyup',  (e) =>
      @schedule(@keyUpinterval)

  saveElement:(async = true) ->
    data = @$form.serialize()
    @page.saving()
    $.ajax({
      type: "POST",
      async: async,
      url: @$form.attr( 'action' ),
      data: @$form.serialize(),
      success: (response) =>
        @previous_value = data
        @page.saved(@)
        @dirty = false
      error: (jqxhr, status, error) =>
        @page.failed(@)
    })

  saveNow: ->
    @unschedule()
    @saveElement(false)

  # remove events scheduled for elem
  unschedule: () ->
    clearTimeout(@scheduled_job) if @scheduled_job
    @scheduled_job = null

  schedule:  (interval) ->
    @unschedule() # remove any existing events
    dirty = (@previous_value != @$form.serialize())
    if dirty
      @page.mark_dirty(this)
      action = () =>
        @saveElement()
      @scheduled_job = setTimeout(action, interval)


class SaveOnChangePage
  constructor: () ->
    @save_indicator = new SaveIndicator($("#save"))
    @intercept_navigation()
    @forms = []
    if $('.live_submit').length
      $('.live_submit').each (i,e) =>
        @forms.push(new SaveOnChange($(e),@))
    @dirty_forms = {}

  intercept_navigation: ->
    $("a").on 'click', (e) =>
      @force_save_dirty()

  saving: (form) ->
    @save_indicator.showSaving()

  saved: (form) ->
    @save_indicator.showSaved()
    @mark_clean(form)

  failed: (form) ->
    @save_indicator.showSaveFailed()

  mark_dirty: (form) ->
    @dirty_forms[form] = form;

  mark_clean: (form) ->
    delete @dirty_forms[form]

  force_save_dirty: ->
    for item, value of @dirty_forms
      value.saveNow()
    for iframe in IFrameSaver.instances
      iframe.save()
    debugger


$(document).ready ->
  window.SaveOnChangePage = SaveOnChangePage
  window.SaveOnChange     = SaveOnChange
  new SaveOnChangePage()
