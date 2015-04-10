# This class implements two main functionalities:

# 1. Checks if global interactive state is availble on page load and if so,
#    it posts 'interactiveLoadGlobal' to all interactives (iframes).
# 2. When 'interactiveStateGlobal' message is received from any iframe, it:
#   2.1. sends the state to LARA server
#   2.2. posts 'interactiveLoadGlobal' message with a new state to all interactives
#        (except from sender of save message).

class GlobalIframeSaver
  INTERACTIVES_SEL = 'iframe.interactive'

  constructor: (config) ->
    @_saveUrl = config.save_url
    @_globalState = if config.raw_data then JSON.parse(config.raw_data) else null

    @_iframePhones = []
    $(INTERACTIVES_SEL).each (idx, iframeEl) =>
      phone = IframePhoneManager.getPhone iframeEl
      @addNewPhone phone

  addNewPhone: (phone) ->
    @_iframePhones.push phone
    @_setupPhoneListeners phone
    if @_globalState
      @_loadGlobalState phone

  _setupPhoneListeners: (phone) ->
    phone.addListener 'interactiveStateGlobal', (state) =>
      @_globalState = state
      @_saveGlobalState()
      @_broadcastGlobalState phone

  _loadGlobalState: (phone) ->
    phone.post 'loadInteractiveGlobal', @_globalState

  _broadcastGlobalState: (sender) ->
    @_iframePhones.forEach (phone) =>
      # Do not send state again to the same iframe that posted global state.
      @_loadGlobalState phone if phone != sender

  _saveGlobalState: ->
    $.ajax
      type: 'POST'
      url: @_saveUrl
      data:
        raw_data: JSON.stringify(@_globalState)
      success: (response) =>
        console.log 'Global interactive save success.'
      error: (jqxhr, status, error) =>
        console.error 'Global interactive save failed!'

if gon.globalInteractiveState?
  window.globalIframeSaver = new GlobalIframeSaver gon.globalInteractiveState
