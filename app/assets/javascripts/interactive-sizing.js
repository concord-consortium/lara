/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

$(document).ready(function () {
    $('[data-aspect-ratio]').each(function (index, element) {
      var $element = $(element);
      var aspectRatio = $element.data('aspect-ratio');
      var currWidth = $element.width();
      $element.attr('width', currWidth);
      $element.attr('height', currWidth / aspectRatio);
    });
});
