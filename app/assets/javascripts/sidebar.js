$(function () {
  // Distance between sidebars (in pixels).
  var SIDEBAR_SPACER = 35;

  // Dynamically setup position of sidebar handles.
  function positionMultipleSidebars() {
    var sidebarTop = $('.sidebar-mod').offset().top;
    var sidebarHdrHeight = $('.sidebar-hdr').height();
    $('.sidebar-mod').each(function (idx) {
      $(this).css('top', sidebarTop + idx * (sidebarHdrHeight + SIDEBAR_SPACER));
    });
  }

  if ($('.sidebar-mod').length > 0) {
    positionMultipleSidebars();

    $('.sidebar-hdr').add('.sidebar-bd-close').click(function () {
      $(this).closest('.sidebar-mod').toggleClass('expanded');
    });
    // It triggers CSS transition.
    $('.sidebar-mod').addClass('visible');
  }
});