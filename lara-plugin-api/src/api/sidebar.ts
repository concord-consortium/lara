import * as $ from "jquery";
import "jquery-ui/ui/widgets/button";

// Distance between sidebar handles (in pixels).
const SIDEBAR_SPACER = 35;
// Distance to the bottom edge of the window if sidebar content gets pretty tall.
const BOTTOM_MARGIN = 30;

export interface ISidebarOptions {
  content: string | HTMLElement;
  /** Icon can be 'default' (arrow) or an HTML element. */
  icon?: string | HTMLElement;
  /** Text displayed on the sidebar handle. */
  handle?: string;
  handleColor?: string;
  /** Title visible after sidebar is opened by user. If it's not provided, it won't be displayed at all. */
  titleBar?: string;
  titleBarColor?: string;
  width?: number;
  padding?: 25;
  onOpen?: () => void;
  onClose?: () => void;
}

export interface ISidebarController {
  open: () => void;
  close: () => void;
}

export const ADD_SIDEBAR_DEFAULT_OPTIONS = {
  /** Arrow pointing left. */
  icon: "default",
  handle: "",
  handleColor: "#aaa",
  titleBar: null,
  titleBarColor: "#bbb",
  width: 500,
  padding: 25
};

// List of all existing sidebars (their controllers).
const controllers: ISidebarController[] = [];

// Dynamically setup position of sidebar handles.
const positionMultipleSidebars = () => {
  // First, make sure that sidebars are below page navigation menu.
  let minOffset = 0;
  const $navMenu = $(".activity-nav-mod");
  // Note that .activity-nav-mod might not be present in test environment.
  if ($navMenu.length > 0) {
    minOffset = $navMenu[0].getBoundingClientRect().bottom;
  }
  // Also, take into account aet of small icons displayed on the side of the page. They look like mini-sidebar handles.
  // Not available in all the layouts, so this selector might not be present. Again, avoid overlapping.
  const $sideNavigation = $("#nav-activity-menu");
  if ($sideNavigation.length > 0) {
    minOffset = Math.max(minOffset, $sideNavigation[0].getBoundingClientRect().bottom);
  }
  minOffset = minOffset + SIDEBAR_SPACER; // add a little margin, it looks better.
  // Then, make sure that multiple handles don't overlap and they don't go off screen.
  const $sidebarHdr = $(".sidebar-hdr");
  const sidebarSpacing = ($sidebarHdr.height() || 0) + SIDEBAR_SPACER;
  const titleBarHeight = $(".sidebar-mod .title-bar").height() || 0;
  $(".sidebar-mod").each(function(idx) {
    const top = minOffset + idx * sidebarSpacing;
    $(this).css("top", top);
    // Also, ensure that sidebar content is fully visible, even on the pretty short screens.
    $(this).find(".sidebar-content").css("max-height", window.innerHeight - top - titleBarHeight - BOTTOM_MARGIN);
  });
};

const closeAllSidebars = () => {
  controllers.forEach(controller => controller.close());
};

/****************************************************************************
 Ask LARA to add a new sidebar.

 Sidebar will be added to the edge of the interactive page window. When multiple sidebars are added, there's no way
 to specify their positions, so no assumptions should be made about current display - it might change.

 Sidebar height cannot be specified. It's done on purpose to prevent issues on very short screens. It's based on the
 provided content HTML element, but it's limited to following range:
 - 100px is the min-height
 - max-height is calculated dynamically and ensures that sidebar won't go off the screen
 If the provided content is taller than the max-height of the sidebar, a sidebar content container will scroll.

 It returns a simple controller that can be used to open or close sidebar.
 ****************************************************************************/
export const addSidebar = (_options: ISidebarOptions): ISidebarController => {
  const options = $.extend({}, ADD_SIDEBAR_DEFAULT_OPTIONS, _options);
  if (options.icon === "default") {
    options.icon = $("<i class='default-icon fa fa-arrow-circle-left'>")[0] as string & HTMLElement;
  }
  // Generate HTML.
  const $sidebar = $('<div class="sidebar-mod">');
  const $handle = $('<div class="sidebar-hdr">');
  const $body = $('<div class="sidebar-bd">');
  // Handle.
  if (options.icon) {
    $handle.append(options.icon);
  }
  const $handleText = $('<h5 class="h5">');
  $handle.append($handleText);
  // Body / main container.
  const $closeBtn = $('<button class="sidebar-bd-close">');
  // Note that ButtonOptions interface is out of date, `icon` is a valid option in jQuery UI 1.12.
  // @ts-ignore
  $closeBtn.button({ icon: "ui-icon-closethick" });
  $body.append($closeBtn);
  const $contentContainer = $('<div class="sidebar-content">');
  $body.append($contentContainer);
  // Final setup.
  $sidebar.append($handle);
  $sidebar.append($body);
  $("body").append($sidebar);

  // Add event handlers.
  const isOpen = () => {
    return $sidebar.hasClass("expanded");
  };
  $handle.add($closeBtn) // .add creates a set of elements, so we can apply click handler just once
    .on("click", () => {
      if (!isOpen()) {
        // We're opening a sidebar. Close all the others first.
        closeAllSidebars();
        if (options.onOpen) {
          options.onOpen();
        }
      }
      if (isOpen() && options.onClose) {
        options.onClose();
      }
      $sidebar.toggleClass("expanded");
    });
  // It triggers CSS transition.
  $(".sidebar-mod").addClass("visible");

  // Apply options.
  $handleText.text(options.handle);
  $contentContainer.append(options.content);
  if (options.titleBar) {
    const $titleBar = $('<div class="title-bar">');
    $body.prepend($titleBar);
    $titleBar.text(options.titleBar);
    $titleBar.css("background", options.titleBarColor);
  }
  $handle.css("background-color", options.handleColor);
  $contentContainer.css("padding", options.padding);
  $sidebar.css("width", options.width);
  // Hide sidebar on load.
  $sidebar.css("right", options.width * -1);

  const controller = {
    open() {
      if (!isOpen()) {
        $handle.trigger("click");
      }
    },
    close() {
      if (isOpen()) {
        $handle.trigger("click");
      }
    }
  };
  controllers.push(controller);

  positionMultipleSidebars();

  // Return controller.
  return controller;
};
