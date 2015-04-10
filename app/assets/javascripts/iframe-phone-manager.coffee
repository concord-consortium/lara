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
    @_iframeCount = 0
    @_phoneData = {}

  _getPhone: (iframeEl, afterConnectedCallback) ->
    data = @_iframePhoneData iframeEl

    if afterConnectedCallback
      if data.phoneAnswered
        # Ensure that callback is *always* executed in an async way.
        setTimeout (-> afterConnectedCallback()), 1
      else
        data.phoneAnsweredCallbacks.push afterConnectedCallback

    data.phone

  _getRpcEndpoint: (iframeEl, namespace) ->
    data = @_iframePhoneData iframeEl

    unless data.rpcEndpoints[namespace]
      data.rpcEndpoints[namespace] = new iframePhone.IframePhoneRpcEndpoint phone: data.phone, namespace: namespace

    data.rpcEndpoints[namespace]

  _iframePhoneData: (iframeEl) ->
    phoneId = $(iframeEl).data 'iframe-phone-id'
    phoneId = @_setupPhoneForIframe(iframeEl) if phoneId == undefined

    @_phoneData[phoneId]

  _setupPhoneForIframe: (iframeEl) ->
    phoneId = @_iframeCount++
    $(iframeEl).data 'iframe-phone-id', phoneId
    @_phoneData[phoneId] =
      phoneAnswered: false
      phoneAnsweredCallbacks: []
      phone: new iframePhone.ParentEndpoint iframeEl, => @_phoneAnswered(iframeEl)
      rpcEndpoints: {}

    phoneId

  _phoneAnswered: (iframeEl) ->
    data = @_iframePhoneData iframeEl
    data.phoneAnswered = true
    callback() for callback in data.phoneAnsweredCallbacks

window.IframePhoneManager = IframePhoneManager
