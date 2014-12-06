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
      $modal
        .html(data.html)
        .prepend($modal_close)
        .css('top', $(window).scrollTop() + 40)
        .show()
      $modal_container.show();
      # for check-answer.js - add click handlers for the new elements
      addModalClickHandlers()

  $(document).on 'click', '#modal .close', ->
    $modal_container.hide()
    $modal.hide()
    false

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