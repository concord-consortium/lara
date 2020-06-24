/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

// Some themes pin the header and some do not
var _headerIsPinnedInThisTheme = null;
function headerIsPinnedInThisTheme() {
  // This currently seems to be the best way to check this. Themes just change
  // CSS so there isn't a way for them add content to the dom or run javascript
  // This is fragile though because someone might mess with .content-hdr and then
  // this will break.
  // We cache the value since this won't change
  if (_headerIsPinnedInThisTheme !== null) {
    return _headerIsPinnedInThisTheme;
  } else {
    _headerIsPinnedInThisTheme = $('.site-width > .content-hdr').is(':visible');
    return _headerIsPinnedInThisTheme;
  }
}

$(document).ready(function () {
  var headerTop = null;

  // Calculate header size
  if ($('.site-width > .content-hdr').length > 0) {
    headerTop = $('.site-width > .content-hdr').offset().top;
  }

  $(window).scroll(function () {
    var windowTop = $(window).scrollTop();

    // Activity nav fixing, if there is one
    if (headerIsPinnedInThisTheme()) {
      if (windowTop >= headerTop / 2) {
        $('.activity-nav-mod.header-nav').addClass('fixed');
        $('.content-hdr').addClass('extra-pad');
        $('.activity-nav-mod.fixed .activity-nav-logo .h2').addClass('visible');
      } else {
        $('.activity-nav-mod.header-nav').removeClass('fixed');
        $('.content-hdr').removeClass('extra-pad');
        $('.activity-nav-mod.header-nav .activity-nav-logo .h2').removeClass('visible');
      }
      if ($('.activity-nav-mod.header-nav').css('position') === 'fixed') {
        $('.question-tab').css({'top': '70px'});
      }
    }
  });

  // Set up colorbox for ImageInteractives - see jquery.colorbox.js
  $('.interactive-mod .colorbox').colorbox({maxWidth: "100%", maxHeight: "100%", minWidth: "960px", photo: true});
  $('.questions-mod .colorbox').colorbox({maxWidth: "100%", maxHeight: "100%", minWidth: "960px", photo: true});
});
