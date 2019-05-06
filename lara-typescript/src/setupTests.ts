// Setup jQuery and jQuery UI in test env. Note that jQuery is NOT included in the build product,
// webpack.config.js specifies jQuery and jQuery UI as externals. It's needed in tests only.
// jQuery UI package is absolutely awful and it's setup and dependency resolving is unclear. This helper
// will set general dependencies. Individual modules should only include widgets they need, e.g.:
// import "jquery-ui/ui/widgets/dialog";
import * as $ from "jquery";
(window as any).$ = $;
(window as any).jQuery = $;
(window as any).jQuery.ui = {};
import "jquery-ui";
import "jquery-ui/ui/widget";
import "jquery-ui/ui/data";
import "jquery-ui/ui/disable-selection";
import "jquery-ui/ui/focusable";
import "jquery-ui/ui/form";
import "jquery-ui/ui/ie";
import "jquery-ui/ui/keycode";
import "jquery-ui/ui/labels";
import "jquery-ui/ui/plugin";
import "jquery-ui/ui/safe-active-element";
import "jquery-ui/ui/safe-blur";
import "jquery-ui/ui/scroll-parent";
import "jquery-ui/ui/tabbable";
import "jquery-ui/ui/unique-id";
import "jquery-ui/ui/version";
