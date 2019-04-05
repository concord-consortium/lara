(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("jQuery"), require("jQuery.ui"), require("Plugins"), require("Sidebar"), require("TextDecorator"));
	else if(typeof define === 'function' && define.amd)
		define(["jQuery", "jQuery.ui", "Plugins", "Sidebar", "TextDecorator"], factory);
	else if(typeof exports === 'object')
		exports["LARA"] = factory(require("jQuery"), require("jQuery.ui"), require("Plugins"), require("Sidebar"), require("TextDecorator"));
	else
		root["LARA"] = factory(root["jQuery"], root["jQuery.ui"], root["Plugins"], root["Sidebar"], root["TextDecorator"]);
})(window, function(__WEBPACK_EXTERNAL_MODULE_jquery__, __WEBPACK_EXTERNAL_MODULE_jqueryui__, __WEBPACK_EXTERNAL_MODULE_plugins__, __WEBPACK_EXTERNAL_MODULE_sidebar__, __WEBPACK_EXTERNAL_MODULE_text_decorator__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = "./src/lara-plugin-api.ts");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./src/lara-plugin-api.ts":
/*!********************************!*\
  !*** ./src/lara-plugin-api.ts ***!
  \********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var $ = __webpack_require__(/*! jquery */ "jquery");
__webpack_require__(/*! jqueryui */ "jqueryui");
var Sidebar = __webpack_require__(/*! sidebar */ "sidebar");
var Plugins = __webpack_require__(/*! plugins */ "plugins");
var TextDecorator = __webpack_require__(/*! text-decorator */ "text-decorator");
var ADD_POPUP_DEFAULT_OPTIONS = {
    title: "",
    autoOpen: true,
    closeButton: true,
    closeOnEscape: false,
    removeOnClose: true,
    modal: false,
    draggable: true,
    resizable: true,
    width: 300,
    height: "auto",
    padding: 10,
    // Note that dialogClass is intentionally undocumented. Styling uses class makes us depend on the
    // current dialog implementation. It might be necessary for LARA themes, although plugins should not use it.
    dialogClass: "",
    backgroundColor: "",
    titlebarColor: "",
    position: { my: "center", at: "center", of: window },
    onOpen: null,
    onBeforeClose: null,
    onResize: null,
    onDragStart: null,
    onDragStop: null
};
/****************************************************************************
 @function addPopup: Ask LARA to add a new popup window
 @arg {IPopupOptions} popupOptions
 @returns {IPopupController} popupController

 Note that many options closely resemble jQuery UI dialog options which is used under the hood.
 You can refer to jQuery UI API docs in many cases: https://api.jqueryui.com/dialog
 Only `content` is required. Other options have reasonable default values (subject to change,
 so if you expect particular behaviour, provide necessary options explicitly).

 React warning: if you use React to render content, remember to call `ReactDOM.unmountComponentAtNode(content)`
 in `onRemove` handler.
 ****************************************************************************/
exports.addPopup = function (_options) {
    var options = $.extend({}, ADD_POPUP_DEFAULT_OPTIONS, _options);
    if (!options.content) {
        throw new Error("LARA.addPopup - content option is required");
    }
    if (options.dialogClass) {
        // tslint:disable-next-line:no-console
        console.warn("LARA.addPopup - dialogClass option is discouraged and should not be used by plugins");
    }
    var $content = typeof options.content === "string" ?
        $("<span>" + options.content + "</span>") : $(options.content);
    var $dialog;
    var remove = function () {
        if (options.onRemove) {
            options.onRemove();
        }
        $dialog.remove();
    };
    $content.dialog({
        title: options.title,
        autoOpen: options.autoOpen,
        closeOnEscape: options.closeOnEscape,
        modal: options.modal,
        draggable: options.draggable,
        width: options.width,
        height: options.height,
        resizable: options.resizable,
        // Note that dialogClass is intentionally undocumented. Styling uses class makes us depend on the
        // current dialog implementation. It might be necessary for LARA themes, although plugins should not use it.
        dialogClass: options.dialogClass,
        position: options.position,
        open: options.onOpen,
        close: function () {
            if (options.onClose) {
                options.onClose();
            }
            // Remove dialog from DOM tree.
            if (options.removeOnClose) {
                remove();
            }
        },
        beforeClose: options.onBeforeClose,
        resize: options.onResize,
        dragStart: options.onDragStart,
        dragStop: options.onDragStop
    });
    $dialog = $content.closest(".ui-dialog");
    $dialog.css("background", options.backgroundColor);
    $dialog.find(".ui-dialog-titlebar").css("background", options.titlebarColor);
    $dialog.find(".ui-dialog-content").css("padding", options.padding);
    if (!options.closeButton) {
        $dialog.find(".ui-dialog-titlebar-close").remove();
    }
    // IPopupController implementation.
    return {
        open: function () {
            $content.dialog("open");
        },
        close: function () {
            $content.dialog("close");
        },
        remove: remove
    };
};
var ADD_SIDEBAR_DEFAULT_OPTIONS = {
    icon: "default",
    handle: "",
    handleColor: "#aaa",
    titleBar: null,
    titleBarColor: "#bbb",
    width: 500,
    padding: 25,
    onOpen: null,
    onClose: null
};
/****************************************************************************
 @function addSidebar: Ask LARA to add a new sidebar
 @arg {ISidebarOptions} sidebarOptions
 @returns {ISidebarController} sidebarController

 Sidebar will be added to the edge of the interactive page window. When multiple sidebars are added, there's no way
 to specify their positions, so no assumptions should be made about current display - it might change.

 Sidebar height cannot be specified. It's done on purpose to prevent issues on very short screens. It's based on the
 provided content HTML element, but it's limited to following range:
 - 100px is the min-height
 - max-height is calculated dynamically and ensures that sidebar won't go off the screen
 If the provided content is taller than the max-height of the sidebar, a sidebar content container will scroll.

 It returns a simple controller that can be used to open or close sidebar.
 ****************************************************************************/
exports.addSidebar = function (options) {
    options = $.extend({}, ADD_SIDEBAR_DEFAULT_OPTIONS, options);
    if (options.icon === "default") {
        options.icon = $("<i class='default-icon fa fa-arrow-circle-left'>")[0];
    }
    return Sidebar.addSidebar(options);
};
/****************************************************************************
 @function saveLearnerPluginState: Ask LARA to save the users state for the plugin
 @arg {string} pluginId - ID of the plugin trying to save data, initially passed to plugin constructor in the context
 @arg {string} state - A JSON string representing serialized plugin state.
 @example
 LARA.saveLearnerPluginState(plugin, '{"one": 1}').then((data) => console.log(data))
 @returns Promise
 ****************************************************************************/
exports.saveLearnerPluginState = function (pluginId, state) {
    return Plugins.saveLearnerPluginState(pluginId, state);
};
/****************************************************************************
 @function decorateContent: Ask LARA to decorate authored content (text / html)
 @arg {string[]} words - a list of case-insensitive words to be decorated. Can use limited regex.
 @arg {string} replace - the replacement string. Can include '$1' representing the matched word.
 @arg {wordClass} wordClass - CSS class used in replacement string. Necessary only if `listeners` are provided too.
 @arg {IEventListeners} listeners - one or more { type, listener } tuples. Note that events are added to `wordClass`
 described above. It's client code responsibility to use this class in the `replace` string.
 @returns void
 ****************************************************************************/
exports.decorateContent = function (words, replace, wordClass, listeners) {
    var domClasses = ["question-txt", "help-content", "intro-txt"];
    var options = {
        words: words,
        replace: replace
    };
    TextDecorator.decorateDOMClasses(domClasses, options, wordClass, listeners);
};
/**************************************************************
 @function registerPlugin
 Register a new external script as `label` with `_class `
 Deligates to this.PluginsApi
 @arg label - the identifier of the script
 @arg _class - the Plugin Class being associated with the identifier
 @returns boolean - true if plugin was registered correctly.
 @example: `LARA.registerPlugin('debugger', Dubugger);
 **************************************************************/
exports.registerPlugin = function (label, _class) {
    return Plugins.registerPlugin(label, _class);
};
/**************************************************************
 @function isTeacherEdition
 Find out if the page being displayed is being run in teacher-edition
 @returns boolean - true if lara is running in teacher-edition
 **************************************************************/
exports.isTeacherEdition = function () {
    // If we decide to do something more complex in the future,
    // the client's API won't change.
    return window.location.search.indexOf("mode=teacher-edition") > 0;
};


/***/ }),

/***/ "jquery":
/*!*************************!*\
  !*** external "jQuery" ***!
  \*************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE_jquery__;

/***/ }),

/***/ "jqueryui":
/*!****************************!*\
  !*** external "jQuery.ui" ***!
  \****************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE_jqueryui__;

/***/ }),

/***/ "plugins":
/*!**************************!*\
  !*** external "Plugins" ***!
  \**************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE_plugins__;

/***/ }),

/***/ "sidebar":
/*!**************************!*\
  !*** external "Sidebar" ***!
  \**************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE_sidebar__;

/***/ }),

/***/ "text-decorator":
/*!********************************!*\
  !*** external "TextDecorator" ***!
  \********************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE_text_decorator__;

/***/ })

/******/ });
});