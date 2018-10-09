/*global $ */

function interactiveSizing () {
  function setSize () {
    var $iframe = $(this);
    var aspectRatio = $iframe.data('aspect-ratio');
    var resizeMethod = $iframe.data('aspect-ratio-method');
    var currWidth = $iframe.width();

    if(resizeMethod === 'MAX') {
      magicNumber = 125;
      newHeight = window.innerHeight - magicNumber;
      $iframe.attr('height', newHeight);
    }
    else {
      $iframe.attr('height', currWidth / aspectRatio);
    }
    $iframe.attr('width', '100%');
  }

  $('[data-aspect-ratio]').each(function () {
    var $iframe = $(this);
    $iframe.on('sizeUpdate', setSize);
    $iframe.trigger('sizeUpdate');
  });
}

$(document).ready(interactiveSizing);

