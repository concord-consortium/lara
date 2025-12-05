# This file should be "required" into your `application.js` via the Asset Pipeline.
#
# Source : https://gist.github.com/1456815

$ ->
  $modal = $('#modal')
  $modal_close = $modal.find('.close')
  $modal_container = $('#modal-container')

  # Handle modal links with the data-remote attribute
  $(document).on 'ajax:success', 'a[data-remote]', (xhr, data, status) ->
    if data.html
      if data.container_class
        $modal_container.addClass(data.container_class)
      $modal
        .html(data.html)
        .prepend($modal_close)
        .addClass(data.css_class)
        .css('top', $(window).scrollTop() + 40)
        .css('margin-bottom', 40)
        .show()
      $modal_container.show();
      # for check-answer.js - add click handlers for the new elements
      addModalClickHandlers()

  $(document).on 'click', '#modal .close', ->
    # Check if any interactive has unsaved changes
    if window.LARA?.AuthoringDirtyState?.hasUnsavedInteractiveChanges?()
      message = window.LARA.AuthoringDirtyState.getDirtyInteractiveMessage()
      unless window.confirm(message)
        return false
      # Clear dirty states if user confirmed
      window.LARA.AuthoringDirtyState.clearAllDirtyStates()
    
    # if an enclosing element has marked itself with reload-on-close reload the page
    if $(this).closest('.reload-on-close').length > 0
      window.reload()
    else
      $modal_container.hide()
      $modal.hide()
    false

  # Handle form submission - check for dirty state before saving
  $(document).on 'submit', '#modal form', (e) ->
    # Check if any interactive has unsaved changes
    if window.LARA?.AuthoringDirtyState?.hasUnsavedInteractiveChanges?()
      message = window.LARA.AuthoringDirtyState.getDirtyInteractiveMessage()
      unless window.confirm(message)
        e.preventDefault()
        return false
      # Clear dirty states if user confirmed
      window.LARA.AuthoringDirtyState.clearAllDirtyStates()
    # Allow form to proceed normally
    true

  $(document).on 'submit', 'form#import', ->
    filedata = new FormData(this)
    $.ajax
      type: "POST"
      url: $(this).attr("action")
      data: filedata
      cache: false
      processData: false
      contentType: false
      error: (data) ->
        message = $.parseJSON(data.responseText)
        $(".message").html message.error
        return

    false
