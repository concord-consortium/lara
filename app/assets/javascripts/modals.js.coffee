# This file should be "required" into your `application.js` via the Asset Pipeline.
#
# Source : https://gist.github.com/1456815

$ ->
  $modal = $('#modal')
  $modal_close = $modal.find('.close')
  $modal_container = $('#modal-container')

  # Handle modal links with the data-remote attribute
  $(document).on 'ajax:success', 'a[data-remote]', (xhr, data, status) ->
    $modal
      .html(data)
      .prepend($modal_close)
      .css('top', $(window).scrollTop() + 40)
      .show()
    $modal_container.show();

  $(document).on 'click', '#modal .close', ->
    $modal_container.hide()
    $modal.hide()
    false