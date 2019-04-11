// Setup jQuery and jQuery UI in test env. Note that jQuery is NOT included in the build product,
// webpack.config.js specifies jQuery and jQuery UI as externals. It's needed in tests only.
// jQuery UI package is absolutely awful and it's setup and dependency resolving is unclear. This helper
// will set general dependencies. Individual modules should only include widgets they need, e.g.:
// import "jquery-ui/ui/widgets/dialog";
const $ = require("jquery");
global.$ = $;
global.jQuery = $;
global.jQuery.ui = {};
require("jquery-ui");
require("jquery-ui/ui/widget");
require("jquery-ui/ui/data");
require("jquery-ui/ui/disable-selection");
require("jquery-ui/ui/focusable");
require("jquery-ui/ui/form");
require("jquery-ui/ui/ie");
require("jquery-ui/ui/keycode");
require("jquery-ui/ui/labels");
require("jquery-ui/ui/plugin");
require("jquery-ui/ui/safe-active-element");
require("jquery-ui/ui/safe-blur");
require("jquery-ui/ui/scroll-parent");
require("jquery-ui/ui/tabbable");
require("jquery-ui/ui/unique-id");
require("jquery-ui/ui/version");
