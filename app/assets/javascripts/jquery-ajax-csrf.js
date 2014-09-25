// Setup CSRF token for all jQuery AJAX requests.
// Note that this file should be included right after jQuery and before other scripts.
$(document).ready(function () {
  var token = $('meta[name="csrf-token"]').attr('content');
  $.ajaxSetup({
    beforeSend: function (xhr) {
      xhr.setRequestHeader('X-CSRF-Token', token);
    }
  });
});
