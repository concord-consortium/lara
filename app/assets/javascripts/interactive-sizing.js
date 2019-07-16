/*global $ */

function interactiveSizing () {
  function setInteractiveWidth($iframe, width) {
    var $container = $iframe.parents(".embeddable-container")
    if ($container.length > 0) {
      $container.css('width', width);
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
      // Q: Why is the height limited only in the DEFAULT mode, but not in MANUAL?
      // A: Some interactives are not responsive, so the author needs a way to force the size of the interactive.
      //    When the interactive height is limited and the browser window is short, the bottom part of a
      //    non responsive interactive will be cut off.
      //    In these cases the author can use the resizeMethod MANUAL.
      //    More info can be found in this story: https://www.pivotaltracker.com/n/projects/736901/stories/161458506
      //    An annoying aspect is that the author needs to figure out what aspectRatio is needed to get the height
      //    they want, and that means the author needs to take into account the page layout (60/40, 70/30).
      //    Also this approach doesn't work well for responsive layout since the width of the interactive is variable,
      //    so the author cannot provide an aspect ratio that guarantees a specific height.
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
