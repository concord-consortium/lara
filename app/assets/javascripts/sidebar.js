(function () {
  // Distance between sidebar handles (in pixels).
  var SIDEBAR_SPACER = 35;
  // Distance to the bottom edge of the window if sidebar content gets pretty tall.
  var BOTTOM_MARGIN = 30;

  // Dynamically setup position of sidebar handles.
  function positionMultipleSidebars() {
    // First, make sure that sidebars are below navigation menu, as if handles overlap with it,
    // it might be problematic to navigate between pages.
    var $navMenu = $('.activity-nav-mod');
    // Note that .activity-nav-mod might not be present in test environment.
    var refHeight = $navMenu.length > 0 ? $navMenu[0].getBoundingClientRect().bottom : 0;
    var startHeight = refHeight + SIDEBAR_SPACER; // add a little margin, it looks better.
    // Then, make sure that multiple handles don't overlap and they don't go off screen.
    var sidebarSpacing = $('.sidebar-hdr').height() + SIDEBAR_SPACER;
    var titleBarHeight = $('.sidebar-mod .title-bar').height();
    $('.sidebar-mod').each(function (idx) {
      const top = startHeight + idx * sidebarSpacing;
      $(this).css('top', top);
      // Also, ensure that sidebar content is fully visible, even on the pretty short screens.
      $(this).find('.sidebar-content').css('max-height', window.innerHeight - top - titleBarHeight - BOTTOM_MARGIN);
    });
  }

  window.Sidebar = {
    // List of all existing sidebars (their controllers).
    _controllers: [],

    _closeAllSidebars: function () {
      this._controllers.forEach(function (controller) {
        controller.close();
      });
    },

    // This function is meant to be used by LARA API. At this point there's no reason to use it directly.
    // LARA API provides reasonable default options too.
    addSidebar: function (options) {
      // Generate HTML.
      var $sidebar = $('<div class="sidebar-mod">');
      var $handle = $('<div class="sidebar-hdr">');
      var $body = $('<div class="sidebar-bd">');
      // Handle.
      if (options.icon) {
        $handle.append(options.icon);
      }
      var $handleText = $('<h5 class="h5">');
      $handle.append($handleText);
      // Body / main container.
      var $closeBtn = $('<button class="sidebar-bd-close">');
      $closeBtn.button({ icon: "ui-icon-closethick" });
      $body.append($closeBtn);
      var $contentContainer = $('<div class="sidebar-content">');
      $body.append($contentContainer);
      // Final setup.
      $sidebar.append($handle);
      $sidebar.append($body);
      $('body').append($sidebar);

      // Add event handlers.
      var isOpen = function () {
        return $sidebar.hasClass('expanded')
      };
      $handle.add($closeBtn) // .add creates a set of elements, so we can apply click handler just once
        .on('click.sidebarToggle', function () {
          if (!isOpen()) {
            // We're opening a sidebar. Close all the others first.
            this._closeAllSidebars();
            if (options.onOpen) {
              options.onOpen();
            }
          }
          if (isOpen() && options.onClose) {
            options.onClose();
          }
          $sidebar.toggleClass('expanded');
        }.bind(this));
      // It triggers CSS transition.
      $('.sidebar-mod').addClass('visible');

      // Apply options.
      $handleText.text(options.handle);
      $contentContainer.append(options.content);
      if (options.titleBar) {
        var $titleBar = $('<div class="title-bar">');
        $body.prepend($titleBar);
        $titleBar.text(options.titleBar);
        $titleBar.css('background', options.titleBarColor);
      }
      $handle.css('background-color', options.handleColor);
      $contentContainer.css('padding', options.padding);
      $sidebar.css('width', options.width);
      // Hide sidebar on load.
      $sidebar.css('right', options.width * -1);

      var controller = {
        open: function () {
          if (!isOpen()) {
            $handle.trigger('click');
          }
        },
        close: function () {
          if (isOpen()) {
            $handle.trigger('click');
          }
        }
      }
      this._controllers.push(controller);

      positionMultipleSidebars();

      // Return controller.
      return controller;
    }
  };
}());
