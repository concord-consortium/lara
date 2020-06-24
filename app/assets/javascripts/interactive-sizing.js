/*global $, scrollInteractiveModOffset, LARA */

function interactiveSizing () {
  function setInteractiveWidth($iframe, width) {
    var $container = $iframe.parents(".embeddable-root");
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
    var height = $iframe.data('height');
    var aspectRatio = $iframe.data('aspect-ratio');
    var resizeMethod = $iframe.data('aspect-ratio-method');
    var maxHeight = window.innerHeight;
    var $container = $iframe.parents(".embeddable-root");

    // Reset dimensions.
    // FIXME: this causes problems with plugin wrappers.  The
    // wrappingContentHeight below will be computed with a width of 100%, but the
    // final result of setSize might make the width less than 100%. So if the
    // wrapping content is flowing text then it might be taller when the width
    // is less.
    // However removing this width reset causes an infite loop because
    // after the size is updated the resize observer fires. And since the
    // size calculation is made based on the new width this results in a new size
    // which triggers the resize observer.... In theory this should settle down
    // after a few iterations but it doesn't.
    setInteractiveWidth($iframe, '100%');

    // if the interactive specifies a height then use that instead of calculating the height
    // using the aspect ratio
    if (height) {
      $iframe.css('height', height);
      return;
    }

    // Decrease maxHeight to account for pinned navigation used in some themes
    maxHeight -= scrollInteractiveModOffset();

    // To be safe make sure we are actually inside of an embeddable root
    if ($container.length > 0) {
      // Decrease the maxHeight with any extra headers or other components
      // wrapping the interactive. If the height of the interactive is limited by maxHeight
      // either by MAX or DEFAULT mode, then the intention is for the full interactive
      // to be visible without scrolling.  Additionally this means the interactive
      // will remain pinned when it is in the the interactive box.
      // NOTE: this looks like a catch-22, but it normally isn't. The value of $container.height() comes from the CSS
      // calculation of the height of the interactive plus all of the extra stuff around it.
      // If the page layout is changing (window resize or columns collapsing), then the $container.height() used in this calcuation
      // might be stale.  However what we are looking at is the difference between that height and the
      // iframe.height(). So long as the stuff around the iframe is not also changing its height then the difference
      // should be constant even as the iframe is changing size.
      var wrappingContentHeight = $container.height() - $iframe.height();
      maxHeight -= wrappingContentHeight;
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

    // Monitor the parent element size so we can update the size of the iframe
    // this is necessary for aspect-ratio based sizing since we might need to
    // adjust the height or width depending on our container.
    // The container size can change when:
    // - the columns are collapsed
    // - we are in responsive layout and the window width is changed.
    // - a wrapping plugin shows or hides additional elements around the interactive
    var ro = new LARA.PageItemAuthoring.ResizeObserver(function(entries, observer) {
      $iframe.trigger('sizeUpdate');
    });
    ro.observe($iframe.parents(".embeddable-root")[0]);
  });

  // Explicitly monitor the window size. In responsive layout we'll see changes
  // in the width of the container with the ResizeObserver above. But we might
  // not see changes in the height.
  // Additionally, in other layouts the page width is fixed so we don't see
  // container size changes when the window size changes.
  // Updating our size is necessary when the interactive is height limited
  // because that calculation is based on window.innerHeight
  $(window).on('resize', function () {
    $('[data-aspect-ratio]').trigger('sizeUpdate');
  });

}

// Use 'load' event so all the images are loaded before we start calculating size.
// Note that wrapping plugins can add images and other elements around interactive.
// 'load' event should handle that (in contrast to 'ready').
$(window).on('load', interactiveSizing);
