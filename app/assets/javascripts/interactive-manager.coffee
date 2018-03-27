# One place for all interactives

class InteractiveManager
  #IFRAMES_SEL = 'iframe.interactive'

  @_instance = null

  # PUBLIC
  # Only class methods are designed to be public.
  @register: (iframeEl) ->
    @_getInstance()._register(iframeEl)

  @_getInstance: ->
    @_instance = new InteractiveManager() unless @_instance
    @_instance

  _register: ($interactive) ->
    $iframe = $interactive.find('iframe[src]')
    $data = $interactive.find('.interactive_data_div')
    # Delete data button is rendered outside interactive container, just next to it.
    $delete_button = $interactive.siblings('.delete_interactive_data').first()
    # IFrameSaver does a lot more than only saving.
    # It also initializes interactive and provides LARA Interactive API.
    # Create IframeSaver even if there's no iframe yet (it might happen when "Click to play" is being used).
    # It ensures that delete data button still works.
    new IFrameSaver($iframe, $data, $delete_button)

    if $iframe.length != 0
      if globalIframeSaver
        globalIframeSaver.addNewInteractive $iframe
      LoggerUtils.logInteractiveEvents($iframe)

window.InteractiveManager = InteractiveManager

$(document).ready ->
  $('.interactive-container').each ()->
    InteractiveManager.register $(this)
