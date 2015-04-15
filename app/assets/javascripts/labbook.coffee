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

    unless @isUpload
      intId = @$element.data('interactive-id')
      @interactiveSel = if intId then "#{INTERACTIVE_SEL}#{intId}" else null

    @$dialog.dialog({
      autoOpen: false,
      width: 750,
      height: 750,
      title: 'Labbook',
      dialogClass: 'lb-dialog',
      modal: true,
      close: =>
        @onDialogClose()
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
    $('#modal-dialog').html("<div class='dialog-error'>#{message}</div>")
    $('#modal-dialog').dialog(title: t('ERROR'), modal: true)

$(document).ready ->
  $('.labbook').each ->
    new LabbookController(this)
