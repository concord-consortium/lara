(function () {
  window.iframed_site_manager = {
    // NOTE: init() must be run after the body tag in application.html.erb
    init: function () {
      try {
        if (window.self !== window.top) {
          // add body class to hide elements (inserted before because body class gets mangled in application.html.erb)
          document.body.className = "iframed " + document.body.className;

          // wait until the full body loads
          $(function () {
            var $document = $(document),
                sendMessage= function (message) {
                  window.parent.postMessage({iframed_site_manager: message}, '*');
                };

            // wait until the parent tells us it needs the iframed-site-manager
            $(window).on('message', function (e) {
              var data = e.originalEvent.data ? e.originalEvent.data.iframed_site_manager : null;
              if (!data) {
                return;
              }

              // start the height poller if needed
              if (data.need_height_poller) {
                var lastHeight = $document.height(),
                    sendHeight, heightPoller;

                sendHeight = function (iframeHeight) {
                  sendMessage({iframe_height: iframeHeight});
                };
                sendHeight(lastHeight);

                heightPoller = function () {
                  var newHeight = $document.height();
                  if (newHeight !== lastHeight) {
                    sendHeight(newHeight);
                    lastHeight = newHeight;
                  }
                };
                setInterval(heightPoller, 100);
              }

              // other iframe site services go here...
            })
          });
        }
      } catch (e) {}
    }
  }
})();
