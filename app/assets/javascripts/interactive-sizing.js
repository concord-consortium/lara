/*global $ */

function interactiveSizing () {
  function setSize () {
    var $iframe = $(this);
    var aspectRatio = $iframe.data('aspect-ratio');
    var resizeMethod = $iframe.data('aspect-ratio-method');
    var maxHeight = window.innerHeight;

    var $pinned = $iframe.parents('.pinned');
    if ($pinned.length > 0) {
      // If interactive is pinned, make sure that maxHeight calculations don't cause interactive to become unpinned
      // (as it gets too tall). Calculate the current difference between height of the interactive and its container.
      // That will automatically handle question header (when interactive saves state) and all the possible margins
      // and padding. Also, take into account a pinned interactive offset (space between the window top border and
      // the interactive container top edge).
      var headersHeight = $pinned.height() - $iframe.height();
      maxHeight -= headersHeight + window.SCROLL_INTERACTIVE_MOD_OFFSET;
    }
    $iframe.attr('width', '100%');

    if (resizeMethod === 'MAX') {
      $iframe.height(maxHeight);
    }
    else if (resizeMethod === 'MANUAL') {
      $iframe.height($iframe.width() / aspectRatio);
    }
    else /* (resizeMethod === 'DEFAULT') */ {
      $iframe.height($iframe.width() / aspectRatio);
      if ($iframe.height() > maxHeight) {
        var scale = (maxHeight / $iframe.height()) * 100 + '%';
        $iframe.attr('width', scale);
        $iframe.height(maxHeight);
        // Rescale question header too (it's present when interactive saves state).
        var $header = $iframe.parents(".embeddable-container").find(".question-hdr")
        if ($header.length > 0) {
          $header.css('width', scale);
        }
      }
    }
  }

  $('[data-aspect-ratio]').each(function () {
    var $iframe = $(this);
    $iframe.on('sizeUpdate', setSize);
    $iframe.trigger('sizeUpdate');
  });

}

$(document).ready(interactiveSizing);

