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
    $delete_button = $("#delete-int-data-#{$data.data('interactive-id')}")

    if $iframe.length != 0
      # IFrameSaver does a lot more than only saving.
      # It also initializes interactive and provides LARA Interactive API.
      new IFrameSaver($iframe, $data, $delete_button)

      if globalIframeSaver
        globalIframeSaver.addNewInteractive $iframe
      LoggerUtils.logInteractiveEvents($iframe)

window.InteractiveManager = InteractiveManager

$(document).ready ->
  $('.interactive-container').each ()->
    InteractiveManager.register $(this)
