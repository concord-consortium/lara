// Initialize responsive layout. It requires some JavaScript.
function responsiveLayout () {
  $(window).on('resize', function () {
    // Trigger update of iframe interactives that define some height or fixed aspect ratio.
    $('[data-height]').trigger('sizeUpdate');
    $('[data-aspect-ratio]').trigger('sizeUpdate');
  });
}
