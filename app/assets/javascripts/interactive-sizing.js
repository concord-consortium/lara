/*global $ */

function interactiveSizing () {
  function setSize () {
    var $iframe = $(this);
    var aspectRatio = $iframe.data('aspect-ratio');
    var currWidth = $('.interactive-mod').width();
    $iframe.attr('width', '100%');
    $iframe.attr('height', currWidth / aspectRatio);
  }

  $('[data-aspect-ratio]').each(function () {
    var $iframe = $(this);
    $iframe.on('sizeUpdate', setSize);
    $iframe.trigger('sizeUpdate');
  });
}

$(document).ready(interactiveSizing);
