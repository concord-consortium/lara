$(function () {
  // Dynamically setup position of sidebar handles.
  function positionMultipleSidebars() {
    var sidebarTop = $('.sidebar-mod').offset().top;
    var sidebarHdrHeight = $('.sidebar-hdr').height() + 35;
    $('.sidebar-mod').each(function (idx) {
      $(this).css('top', sidebarTop + idx * sidebarHdrHeight);
    });
  }
  positionMultipleSidebars();

  $('.sidebar-hdr').add('.sidebar-bd-close').click(function () {
    $(this).closest('.sidebar-mod').toggleClass('expanded');
  });

  $('.sidebar-mod').addClass('visible');
});