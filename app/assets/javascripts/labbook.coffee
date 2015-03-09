class LabbookController
  TAKE_SNAPSHOT_SEL = '.take-lb-snapshot'
  OPEN_ALBUM_SEL = '.open-lb-album'
  DIALOG_SEL = '.lb-dialog-content'
  INTERACTIVE_SEL = '#interactive_' # incomplete, we need to provide ID
  WAIT_MSG_SEL = '.lb-wait-msg'

  constructor: (labbookElement) ->
    @$element = $(labbookElement)
    @$openAlbumBtn = @$element.find(OPEN_ALBUM_SEL)
    @$takeSnapshotBtn = @$element.find(TAKE_SNAPSHOT_SEL)
    @$dialog = @$element.find(DIALOG_SEL)
    @$iframe = @$dialog.find('iframe')

    @baseUrl = @$element.data('labbook-url')
    @albumId = @$element.data('labbook-album-id')

    interactiveId = @$element.data('interactive-id')
    if interactiveId
      @snapshotEnabled = true
      @interactiveSel = INTERACTIVE_SEL + interactiveId
    else
      @snapshotEnabled = false

    @$dialog.dialog({
      autoOpen: false,
      width: 750,
      height: 750,
      title: 'Labbook',
      dialogClass: 'lb-dialog',
      modal: true
    })

    @registerListeners()
    @updateView()

  registerListeners: ->
    @$openAlbumBtn.on 'click', =>
      @openAlbum()

    @$takeSnapshotBtn.on 'click', =>
      @takeSnapshot()

  updateView: ->
    if @snapshotEnabled
      @$takeSnapshotBtn.show()
    else
      @$takeSnapshotBtn.hide()

  openAlbum: ->
    @setIframeUrl("#{@baseUrl}/albums?#{@albumId}")
    @showDialog()

  takeSnapshot: ->
    return unless @snapshotEnabled
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

  setIframeUrl: (newUrl) ->
    oldUrl = @$iframe.attr('src')
    # Check old URL, so iframe won't be reloaded if it's not necessary.
    if newUrl != oldUrl
      @startWaiting(t('LOADING_LABBOOK'))
      @$iframe.hide()
      @$iframe.attr('src', newUrl)
      @$iframe.one 'load', =>
        @stopWaiting()
        @$iframe.fadeIn()

  startWaiting: (message) ->
    startWaiting(message, WAIT_MSG_SEL) # defined in wait-message.js

  stopWaiting: ->
    stopWaiting(WAIT_MSG_SEL) # defined in wait-message.js

  showError: (message) ->
    @$dialog.dialog('close')
    $('#modal-dialog').html('<div class="server-error">#{message}</div>')
    $('#modal-dialog').dialog(title: 'Network error', modal: true, dialogClass: 'network-error')

$(document).ready ->
  $('.labbook').each ->
    new LabbookController(this)
