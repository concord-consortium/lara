// Space between window top border and the interactive container.
window.SCROLL_INTERACTIVE_MOD_OFFSET = 75; // px

$(window).ready(function () {
  var offset = window.SCROLL_INTERACTIVE_MOD_OFFSET;
  var $sticky = $('.pinned');
  if ($sticky.length === 0) {
    return;
  }

  var $trackEnd = $('.end-scroll-track');
  var originalCss = {};
  var $window = $(window);
  var $stickyClone;

  function cloneDomItem($elem, elemTag) {
    var $returnElm = $(elemTag);
    $returnElm.addClass($elem.attr('class'));
    $returnElm.attr('id', $elem.attr('id'));
    $returnElm.attr('style', $elem.attr('style'));
    $returnElm.css('height', $elem.height());
    return $returnElm;
  }

  function pin() {
    originalCss.position = $sticky[0].style.position;
    originalCss.top = $sticky[0].style.top;
    originalCss.width = $sticky[0].style.width;
    // Attach a clone to replace the "missing" body height.
    $stickyClone = cloneDomItem($sticky, '<div>');
    $stickyClone = $stickyClone.insertBefore($sticky);
    $sticky.css('position', 'fixed');
  }

  function unpin() {
    if (!$stickyClone) {
      return;
    }
    // Since $sticky is in the viewport again, we can remove the clone and the class.
    $stickyClone.remove();
    $stickyClone = null;
    $sticky[0].style.position = originalCss.position;
    $sticky[0].style.top = originalCss.top;
    $sticky[0].style.width = originalCss.width;
  }

  function handleScroll(e) {
    var stickyHeight = $sticky.height() + offset;
    if (stickyHeight > $window.height()) {
      // Element is too high to pin it.
      unpin();
      return;
    }

    var scrollTop = $window.scrollTop();
    // If sticky clone is available, use it to define waypoint. It's in the original spot.
    // Sticky element is already moving while user is scrolling.
    var stickyTop = ($stickyClone || $sticky).offset().top - offset;

    if (scrollTop >= stickyTop && !$stickyClone) {
      pin();
    } else if (scrollTop < stickyTop && $stickyClone) {
      unpin();
    }

    if ($stickyClone) { // element is pinned
      var trackTop = $trackEnd.offset().top;
      if (scrollTop + stickyHeight > trackTop) {
        // Pins interactive to the bottom track.
        $sticky.css('top', offset + trackTop - scrollTop - stickyHeight);
      } else {
        // Pins interactive to the top edge.
        $sticky.css('top', offset);
      }
      // Necessary to maintain width of the pinned element.
      $sticky.width($stickyClone.width());
    }
  }

  $window.on('scroll', handleScroll);

  // Monitor the parent size so we can update the size of the fixed element
  // when the width or height of the parent changes
  var ro = new LARA.PageItemAuthoring.ResizeObserver((entries, observer) => {
    handleScroll();
  });
  ro.observe($sticky.parent()[0]);
});
