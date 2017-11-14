/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

$(document).ready(function () {
  var headerTop = null;

  // Calculate header size
  if ($('.site-width > .content-hdr').length > 0) {
    headerTop = $('.site-width > .content-hdr').offset().top;
  }

  $(window).scroll(function () {
    var windowTop = $(window).scrollTop();

    // Activity nav fixing, if there is one
    if (headerTop) {
      if (windowTop >= headerTop / 2) {
        $('.activity-nav-mod').addClass('fixed');
        $('.content-hdr').addClass('extra-pad');
        $('.activity-nav-mod.fixed .activity-nav-logo .h2').addClass('visible');
      } else {
        $('.activity-nav-mod').removeClass('fixed');
        $('.content-hdr').removeClass('extra-pad');
        $('.activity-nav-mod .activity-nav-logo .h2').removeClass('visible');
      }
    }
  });

  // Set up colorbox for ImageInteractives - see jquery.colorbox.js
  $('.interactive-mod .colorbox').colorbox({maxWidth: "100%", maxHeight: "100%", minWidth: "960px", photo: true});
});
