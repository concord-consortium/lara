// Just add element with 'wait-message' class to your page and then call
// startWaiting(<some message>) and stopWaiting when long action is complete.
function startWaiting(message) {
  jQuery('.wait-message').show();
  var $div = jQuery('<div>').appendTo('.wait-message');
  jQuery('<i class="wait-icon fa fa-spinner fa-spin">').appendTo($div);
  jQuery('<span class="wait-text">').text(message).appendTo($div);
}

function stopWaiting() {
  jQuery('.wait-message').empty().hide();
}
