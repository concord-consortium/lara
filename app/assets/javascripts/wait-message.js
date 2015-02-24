// Just add element with 'wait-message' class to your page and then call
// startWaiting(<some message>) and stopWaiting when long action is complete.
function startWaiting(message,element) {
  if (element == null) {
    element = '.wait-message';
  }
  jQuery(element).show();
  var $div = jQuery('<div>').appendTo(element);
  jQuery('<i class="wait-icon fa fa-spinner fa-spin">').appendTo($div);
  jQuery('<span class="wait-text">').text(message).appendTo($div);
}

function stopWaiting(element) {
  if (element == null) {
    element = '.wait-message';
  }
  jQuery(element).empty().hide();
}
