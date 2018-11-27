// Initialize responsive layout. It requires some JavaScript.
function responsiveLayout () {
  $(window).on('resize', function () {
    // Trigger update of iframe interactives that define some fixed aspect ratio.
    $('[data-aspect-ratio]').trigger('sizeUpdate');
  });
}
