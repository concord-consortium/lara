/*global $ */

function interactiveSizing () {
  function setInteractiveWidth($iframe, width) {
    $iframe.css('width', width);
    var $header = $iframe.parents(".embeddable-container").find(".question-hdr")
    if ($header.length > 0) {
      $header.css('width', width);
    }
  }

  function limitInteractiveHeight($iframe, maxHeight) {
    if ($iframe.height() > maxHeight) {
      var scale = (maxHeight / $iframe.height()) * 100 + '%';
      setInteractiveWidth($iframe, scale);
      $iframe.css('height', maxHeight);
    }
  }

  function setSize () {
    var $iframe = $(this);
    var aspectRatio = $iframe.data('aspect-ratio');
    var resizeMethod = $iframe.data('aspect-ratio-method');
    var maxHeight = window.innerHeight;

    var $pinned = $iframe.parents('.pinned');
    var isPinned = $pinned.length > 0;
    var multipleInteractives = isPinned && $pinned.children().length > 1;

    // Reset dimensions.
    setInteractiveWidth($iframe, '100%');

    if (isPinned && multipleInteractives) {
      // This case is treated in a basic way for now. MAX setting doesn't make much sense.
      // We just set aspect ratio (either provided by user or interactive) and we don't limit interactive height.
      // So, interactives might get 'unpinned' as a result. It could have been treated better in the future,
      // if there's a need for that.
      $iframe.css('height', $iframe.width() / aspectRatio);
      return;
    }

    if (isPinned) {
      // If interactive is pinned (and there's only one interactive), make sure that maxHeight calculations don't
      // cause interactive to become unpinned (as it gets too tall). Calculate the current difference between height
      // of the interactive and its container. That will automatically handle question header (when interactive saves
      // state) and all the possible margins and padding. Also, take into account a pinned interactive offset (space
      // between the window top border and the interactive container top edge).
      var headersHeight = $pinned.height() - $iframe.height();
      maxHeight -= headersHeight + window.SCROLL_INTERACTIVE_MOD_OFFSET;
    }

    if (resizeMethod === 'MAX') {
      $iframe.css('height', maxHeight);
    }
    else if (resizeMethod === 'MANUAL') {
      $iframe.css('height', $iframe.width() / aspectRatio);
    }
    else /* (resizeMethod === 'DEFAULT') */ {
      $iframe.css('height', $iframe.width() / aspectRatio);
      // PJ [7/16/2019]: Why is the height limited only in the DEFAULT mode, but not in MANUAL?
      // I don't find this intuitive, but it has been implemented because of some issues described
      // in this story: https://www.pivotaltracker.com/n/projects/736901/stories/161458506
      limitInteractiveHeight($iframe, maxHeight);
    }
  }

  $('[data-aspect-ratio]').each(function () {
    var $iframe = $(this);
    $iframe.on('sizeUpdate', setSize);
    $iframe.trigger('sizeUpdate');
  });
}

// Use 'load' event so all the images are loaded before we start calculating size.
// Note that wrapping plugins can add images and other elements around interactive.
// 'load' event should handle that (in contrast to 'ready').
$(window).on('load', interactiveSizing);
