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
    $delete_button = $interactive.find('.delete_interactive_data')
    $click_to_play = $interactive.find('.click_to_play.shown')

    if $iframe.length != 0
      if $interactive.hasClass('savable')
        new IFrameSaver($iframe, $data, $delete_button)

      if globalIframeSaver
        globalIframeSaver.addNewInteractive $iframe

      LoggerUtils.logInteractiveEvents($iframe)

window.InteractiveManager = InteractiveManager

$(document).ready ->
  $('.interactive-container').each ()->
    InteractiveManager.register $(this)