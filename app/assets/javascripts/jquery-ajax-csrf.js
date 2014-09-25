// Setup CSRF token for all jQuery AJAX requests.
// Note that this file should be included right after jQuery and before other scripts.
$(document).ready(function () {
  var token = $('meta[name="csrf-token"]').attr('content');
  // "Free" URI parser in JS.
  var urlParser = document.createElement('a');
  $.ajaxSetup({
    beforeSend: function (xhr, settings) {
      // Note that <a> element will set .hostname to correct value even
      // if we provide relative path like '/api/v1/something'.
      // Set X-CSRF-Token only while issuing request to LARA API,
      // as this header was e.g. breaking Shutterbug service.
      urlParser.href = settings.url;
      if (urlParser.hostname == window.location.hostname) {
        xhr.setRequestHeader('X-CSRF-Token', token);
  	  }
    }
  });
});
