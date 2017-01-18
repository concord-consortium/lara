#
#  LARA <-> Labook Communications Protocol Note
#
#  To keep users from closing the iframed Labook dialog while they have unsaved changes a simple IFramePhone based protocol
#  has been added which works like this:
#
#  * Lara sets up iframe listeners for two messages: "connected" and "close" and then flags the iframe as not implementing IFramePhone.
#    The connected message sets the iframe handling flag and the close message forces the dialog to close.
#
#  * Then Iframed Labook page with then drawing tool setps up listeners for "canClose" and then sends "connected":true to Lara.  Other
#    Labook pages, such as the index page, do not setup IFramePhone handlers and don't send the connected message.
#
#  * A user then clicks on the close button in iframe modal dialog titlebar.  If the iframe is marked as implementing IFramePhone the mouse event
#    is cancelled which causes the modal not to close and a "canClose" message is sent to the Labook
#
#  * The Labook "canClose" handler checks an internal "dirty" flag it mantains.  If the document is not dirty a "connected":false message
#    is first sent to Lara followed by a "close" message which causes the dialog to close. If the document is dirty a confirmation dialog is
#    shown asking the user if they really want to exit with unsaved changes.  If the user selects the yes button the same set of messages is
#    sent to Lara as when the document is not dirty, causing Lara to close the dialog.  The Labook uses the same "canClose" handler
#    when the cancel button is clicked within it.
#
#  * When the save button is pressed in the Labook it sends a "connected":false message to Lara after the data is saved and right before it
#    redirects to the Labook index page in the form submit handler.  This disables the check in the modal titlebar close handler.
#

class LabbookController
  ACTION_BTN_SEL = '.lb-action-btn'
  OPEN_ALBUM_SEL = '.lb-album-btn'
  DIALOG_SEL = '.lb-dialog-content'
  INTERACTIVE_SEL = '#interactive_' # incomplete, we need to provide ID
  WAIT_MSG_SEL = '.lb-wait-msg'

  constructor: (labbookElement) ->
    @$element = $(labbookElement)
    @$openAlbumBtn = @$element.find(OPEN_ALBUM_SEL)
    @$actionBtn = @$element.find(ACTION_BTN_SEL)
    @$dialog = @$element.find(DIALOG_SEL)
    @$iframe = @$dialog.find('iframe')

    @baseUrl = @$element.data('labbook-url')
    @laraUpdateUrl = @$element.data('lara-update-url')
    @albumId = @$element.data('labbook-album-id')

    @isUpload = @$element.data('is-upload')

    @implementsIFramePhone = false
    @canClose = false

    unless @isUpload
      intId = @$element.data('interactive-id')
      @interactiveSel = if intId then "#{INTERACTIVE_SEL}#{intId}" else null

    @$dialog.dialog({
      autoOpen: false,
      width: Math.min(window.innerWidth - 10, 750),
      height: Math.min(window.innerHeight - 10, 750),
      title: 'Labbook',
      dialogClass: 'lb-dialog',
      modal: true,
      close: =>
        @onDialogClose()
      beforeClose: =>
        @onDialogClosing()
    })

    @registerListeners()

  registerListeners: ->
    @$openAlbumBtn.on 'click', =>
      @openAlbum()

    @$actionBtn.on 'click', =>
      if @isUpload
        @uploadImage()
      else
        @takeSnapshot()

  openAlbum: ->
    @setIframeUrl("#{@baseUrl}/albums?#{@albumId}")
    @showDialog()

  uploadImage: ->
    @setIframeUrl("#{@baseUrl}/albums?#{@albumId}&todo=new")
    @showDialog()

  takeSnapshot: ->
    unless @interactiveSel
      @showError(t('MISSING_INTERACTIVE'))
      return

    @startWaiting(t('PLEASE_WAIT_TAKING_SNAPSHOT'))
    @$iframe.hide()
    @showDialog()
    Shutterbug.snapshot({
      selector: @interactiveSel,
      done: (imgSrc) =>
        @stopWaiting()
        @setIframeUrl("#{@baseUrl}/albums?#{@albumId}&todo=create&source_url=#{imgSrc}")
      fail: =>
        @stopWaiting()
        @showError(t('SNAPSHOT_FAILED'))
    })

  showDialog: ->
    @$dialog.dialog('open')

  onDialogClosing: (event) ->
    return true if not @implementsIFramePhone or @canClose
    @phone.post('canClose')
    return false

  onDialogClose: ->
    # Notify LARA that dialog has been closed, so album has been (probably!) updated.
    # That information is needed to support Portal reports and run with collaborators.
    saveIndicator = SaveIndicator.instance()
    saveIndicator.showSaving()
    $.ajax({
      type: 'PUT',
      url: @laraUpdateUrl,
      success: ->
        saveIndicator.showSaved()
      error: (jqxhr)->
        if jqxhr.status is 401
          saveIndicator.showUnauthorized()
          $(document).trigger 'unauthorized'
        else
          saveIndicator.showSaveFailed()
    })

  setIframeUrl: (newUrl) ->
    @canClose = false
    @implementsIFramePhone = false

    @startWaiting(t('LOADING_LABBOOK'))
    @$iframe.hide()
    @$iframe.attr('src', newUrl)
    @$iframe.one 'load', =>
      @setupPhone()
      @stopWaiting()
      @$iframe.fadeIn()

  setupPhone: ->
    @phone = IframePhoneManager.getPhone @$iframe[0], =>
    @phone.addListener 'close', =>
      @canClose = true
      @$dialog.dialog('close')
    @phone.addListener 'connected', (connected) =>
      @implementsIFramePhone = connected

  startWaiting: (message) ->
    startWaiting(message, WAIT_MSG_SEL) # defined in wait-message.js

  stopWaiting: ->
    stopWaiting(WAIT_MSG_SEL) # defined in wait-message.js

  showError: (message) ->
    @$dialog.dialog('close')
    $('#modal-dialog').html("<div class='dialog-error'>#{message}</div>")
    $('#modal-dialog').dialog(title: t('ERROR'), modal: true)

$(document).ready ->
  $('.labbook').each ->
    new LabbookController(this)
