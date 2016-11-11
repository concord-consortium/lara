# This class implements two main functionalities:

# 1. Checks if global interactive state is availble on page load and if so,
#    it posts 'interactiveLoadGlobal' to all interactives (iframes).
# 2. When 'interactiveStateGlobal' message is received from any iframe, it:
#   2.1. sends the state to LARA server
#   2.2. posts 'interactiveLoadGlobal' message with a new state to all interactives
#        (except from sender of save message).

class GlobalIframeSaver

  constructor: (config) ->
    @_saveUrl = config.save_url
    @globalState = if config.raw_data then JSON.parse(config.raw_data) else null
    @_saveIndicator = SaveIndicator.instance()

    @_iframePhones = []

  addNewInteractive: (iframeEl) ->
    phone = IframePhoneManager.getPhone $(iframeEl)[0]
    @_iframePhones.push phone
    @_setupPhoneListeners phone
    if @globalState
      @_loadGlobalState phone

  _setupPhoneListeners: (phone) ->
    phone.addListener 'interactiveStateGlobal', (state) =>
      @globalState = state
      @_saveGlobalState()
      @_broadcastGlobalState phone

  _loadGlobalState: (phone) ->
    phone.post 'loadInteractiveGlobal', @globalState

  _broadcastGlobalState: (sender) ->
    @_iframePhones.forEach (phone) =>
      # Do not send state again to the same iframe that posted global state.
      @_loadGlobalState phone if phone != sender

  _saveGlobalState: ->
    @_saveIndicator.showSaving()
    $.ajax
      type: 'POST'
      url: @_saveUrl
      data:
        raw_data: JSON.stringify(@globalState)
      success: (response) =>
        console.log 'Global interactive save success.'
        @_saveIndicator.showSaved()
      error: (jqxhr, status, error) =>
        console.error 'Global interactive save failed!'
        if jqxhr.status is 401
          @_saveIndicator.showUnauthorized()
          $(document).trigger 'unauthorized'
        else
          @_saveIndicator.showSaveFailed()


window.GlobalIframeSaver = GlobalIframeSaver

$(document).ready ->
  if gon.globalInteractiveState?
    window.globalIframeSaver = new GlobalIframeSaver gon.globalInteractiveState
