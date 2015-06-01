class SaveIndicator
  @default_id: "#save"
  @instances: {}
  @instance: (id=@default_id) ->
    existing = @instances[id]
    existing || new SaveIndicator(id)

  constructor: (id=SaveIndicator.default_id) ->
    SaveIndicator.instances[id] = @
    @saveTimer  = null
    @$elem      = $(id)
    @clear()  # start hidden.

  clear: ->
    @$elem.removeClass('msg-visible')
    @$elem.removeClass('error')
    @$elem.css('opacity', 0)

  showSaveFailed: (message="Save failed!") ->
    @$elem.addClass('msg-visible')
    @$elem.addClass("error")
    @$elem.html(message)

  showUnauthorized: (message="Unauthorized!") ->
    @$elem.addClass('msg-visible')
    @$elem.addClass('error')
    @$elem.html(message)

  showSaved: (message="Saved.") ->
    # Wait a ½ second before actually displaying:
    @saveTimer = setTimeout =>
      @$elem.addClass('msg-visible')
      @$elem.removeClass('error')
      @$elem.html(message)
      @$elem.animate({'opacity': '0'}, {duration: 'slow', complete: => @clear()}) # Fade out.
    , 500

  showSaving: ->
    @$elem.addClass('msg-visible')
    @$elem.removeClass('error')
    @$elem.html('Saving...')
    @$elem.css({'opacity': '0.5'})
    @$elem.animate({'opacity': '1.0'}, 'fast')

$(document).ready ->
  window.SaveIndicator = SaveIndicator
