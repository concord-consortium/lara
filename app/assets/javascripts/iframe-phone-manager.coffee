# Manager of the iframe phone instances.
# Do not use iframePhone module directly, use this class instead.

class IframePhoneManager
  IFRAMES_SEL = 'iframe.interactive'

  @_instance = null

  # PUBLIC
  # Only class methods are designed to be public.
  @getPhone: (iframeEl, afterConnectedCallback) ->
    @_getInstance()._getPhone(iframeEl, afterConnectedCallback)

  @getRpcEndpoint: (iframeEl, namespace) ->
    @_getInstance()._getRpcEndpoint(iframeEl, namespace)

  @_getInstance: ->
    @_instance = new IframePhoneManager() unless @_instance
    @_instance

  # PRIVATE
  # Instance methods are not intented to be used externally, not even constructor, they are all private.
  constructor: ->
    @_iframeData = {}
    @_processAllIframes()

  _getPhone: (iframeEl, afterConnectedCallback) ->
    data = @_iframeData[iframeEl]
    return null unless data

    if afterConnectedCallback
      if data.phoneAnswered
        # Ensure that callback is *always* executed in an async way.
        setTimeout (-> afterConnectedCallback()), 1
      else
        data.phoneAnsweredCallbacks.push afterConnectedCallback

    data.phone

  _getRpcEndpoint: (iframeEl, namespace) ->
    data = @_iframeData[iframeEl]
    return null unless data

    unless data.rpcEndpoints[namespace]
      data.rpcEndpoints[namespace] = new iframePhone.IframePhoneRpcEndpoint phone: data.phone, namespace: namespace

    data.rpcEndpoints[namespace]

  _processAllIframes: ->
    $(IFRAMES_SEL).each (idx, iframeEl) =>
      @_iframeData[iframeEl] =
        phoneAnswered: false
        phoneAnsweredCallbacks: []
        phone: new iframePhone.ParentEndpoint iframeEl, => @_phoneAnswered(iframeEl)
        rpcEndpoints: {}

  _phoneAnswered: (iframeEl) ->
    data = @_iframeData[iframeEl]
    data.phoneAnswered = true
    callback() for callback in data.phoneAnsweredCallbacks

window.IframePhoneManager = IframePhoneManager
