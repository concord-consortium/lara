/*global $ */

function interactiveSizing () {
  function setSize () {
    var $iframe = $(this);
    var aspectRatio = $iframe.data('aspect-ratio');
    var resizeMethod = $iframe.data('aspect-ratio-method');
    var magicNumber = 125;
    var maxHeight = window.innerHeight - magicNumber;

    if(resizeMethod === 'MAX') {
      $iframe.height(maxHeight);
      $iframe.attr('width', '100%');
    }
    else {
      $iframe.attr('width', '100%');
      $iframe.height($iframe.width() / aspectRatio);
      if ($iframe.height() > maxHeight) {
        var scale = maxHeight / $iframe.height();
        $iframe.attr('width', scale * 100 + '%');
        $iframe.height(maxHeight);
      }
    }
  }

  $('[data-aspect-ratio]').each(function () {
    var $iframe = $(this);
    $iframe.on('sizeUpdate', setSize);
    $iframe.trigger('sizeUpdate');
  });

}

$(document).ready(interactiveSizing);

