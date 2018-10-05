/******/ (function(modules) { // webpackBootstrap
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
/******/ 	return __webpack_require__(__webpack_require__.s = 0);
/******/ })
/************************************************************************/
/******/ ({

/***/ "./app/assets/javascripts/webpack/components/aspect_ratio_chooser.tsx":
/*!****************************************************************************!*\
  !*** ./app/assets/javascripts/webpack/components/aspect_ratio_chooser.tsx ***!
  \****************************************************************************/
/*! exports provided: AspectRatioChooser */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, \"AspectRatioChooser\", function() { return AspectRatioChooser; });\n/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ \"react\");\n/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);\nvar __extends = (undefined && undefined.__extends) || (function () {\n    var extendStatics = function (d, b) {\n        extendStatics = Object.setPrototypeOf ||\n            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||\n            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };\n        return extendStatics(d, b);\n    }\n    return function (d, b) {\n        extendStatics(d, b);\n        function __() { this.constructor = d; }\n        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());\n    };\n})();\n\n// By making state a class we can define default values.\nvar AspectRatioChooserState = /** @class */ (function () {\n    function AspectRatioChooserState() {\n        this.width = 0;\n        this.height = 0;\n        this.mode = \"DEFAULT\";\n    }\n    return AspectRatioChooserState;\n}());\n;\nvar AspectRatioChooser = /** @class */ (function (_super) {\n    __extends(AspectRatioChooser, _super);\n    function AspectRatioChooser() {\n        return _super !== null && _super.apply(this, arguments) || this;\n    }\n    AspectRatioChooser.prototype.getInitialState = function () {\n        return {\n            width: this.props.initialState.width,\n            height: this.props.initialState.height,\n            mode: this.props.initialState.mode\n        };\n    };\n    AspectRatioChooser.prototype.myUpdate = function (changes) {\n        var _this = this;\n        this.setState(changes);\n        var delayedUpdate = function () {\n            return _this.props.updateValues(_this.state);\n        };\n        return setTimeout(delayedUpdate, 1);\n    };\n    AspectRatioChooser.prototype.render = function () {\n        var _this = this;\n        var _a = this.state, mode = _a.mode, width = _a.width, height = _a.height;\n        var availableAspectRatios = this.props.availableAspectRatios;\n        var disabledInputs = mode === 'MANUAL' ? false : true;\n        var inputStyle = {\n            'display': 'flex',\n            'flex-direction': 'row',\n            'flex-wrap': 'wrap',\n            'margin-right': '0.5em',\n            'opacity': disabledInputs ? '0.5' : '1.0'\n        };\n        return (react__WEBPACK_IMPORTED_MODULE_0__[\"createElement\"](\"div\", { style: inputStyle },\n            react__WEBPACK_IMPORTED_MODULE_0__[\"createElement\"](\"select\", { onChange: function (e) { return _this.myUpdate({ mode: e.target.value }); } })));\n    };\n    return AspectRatioChooser;\n}(react__WEBPACK_IMPORTED_MODULE_0__[\"Component\"]));\n\n\n\n//# sourceURL=webpack:///./app/assets/javascripts/webpack/components/aspect_ratio_chooser.tsx?");

/***/ }),

/***/ "./app/assets/javascripts/webpack/components/noah-div.tsx":
/*!****************************************************************!*\
  !*** ./app/assets/javascripts/webpack/components/noah-div.tsx ***!
  \****************************************************************/
/*! exports provided: NoahDiv */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, \"NoahDiv\", function() { return NoahDiv; });\n/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ \"react\");\n/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);\nvar __extends = (undefined && undefined.__extends) || (function () {\n    var extendStatics = function (d, b) {\n        extendStatics = Object.setPrototypeOf ||\n            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||\n            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };\n        return extendStatics(d, b);\n    }\n    return function (d, b) {\n        extendStatics(d, b);\n        function __() { this.constructor = d; }\n        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());\n    };\n})();\n\n// By making state a class we can define default values.\nvar NoahDivState = /** @class */ (function () {\n    function NoahDivState() {\n    }\n    return NoahDivState;\n}());\nvar NoahDiv = /** @class */ (function (_super) {\n    __extends(NoahDiv, _super);\n    function NoahDiv() {\n        return _super !== null && _super.apply(this, arguments) || this;\n    }\n    NoahDiv.prototype.render = function () {\n        var inputStyle = {\n            'display': 'flex',\n            'flex-direction': 'row',\n            'flex-wrap': 'wrap',\n            'justify-content': 'space-around',\n            'padding': '0.5em',\n            'background-color': 'hsl(0,10%,90%)'\n        };\n        return (react__WEBPACK_IMPORTED_MODULE_0__[\"createElement\"](\"div\", { style: inputStyle },\n            react__WEBPACK_IMPORTED_MODULE_0__[\"createElement\"](\"div\", null, \" This is NOAHS BRAND NEW TAG \"),\n            react__WEBPACK_IMPORTED_MODULE_0__[\"createElement\"](\"div\", null,\n                \" \",\n                this.props.label,\n                \" \")));\n    };\n    return NoahDiv;\n}(react__WEBPACK_IMPORTED_MODULE_0__[\"Component\"]));\n\n\n\n//# sourceURL=webpack:///./app/assets/javascripts/webpack/components/noah-div.tsx?");

/***/ }),

/***/ "./app/assets/javascripts/webpack/index.ts":
/*!*************************************************!*\
  !*** ./app/assets/javascripts/webpack/index.ts ***!
  \*************************************************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
eval("__webpack_require__.r(__webpack_exports__);\n/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ \"react\");\n/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);\n/* harmony import */ var react_dom__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! react-dom */ \"react-dom\");\n/* harmony import */ var react_dom__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(react_dom__WEBPACK_IMPORTED_MODULE_1__);\n/* harmony import */ var _components_aspect_ratio_chooser__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./components/aspect_ratio_chooser */ \"./app/assets/javascripts/webpack/components/aspect_ratio_chooser.tsx\");\n/* harmony import */ var _components_noah_div__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./components/noah-div */ \"./app/assets/javascripts/webpack/components/noah-div.tsx\");\n\n\n\n\nwindow.RenderComponent = function (component, props, dom) {\n    react_dom__WEBPACK_IMPORTED_MODULE_1__[\"render\"](react__WEBPACK_IMPORTED_MODULE_0__[\"createElement\"](component, props), dom);\n};\nvar defineWindowGlobal = function (key, value) {\n    window[key] = value;\n};\ndefineWindowGlobal('AspectRatioChooser', _components_aspect_ratio_chooser__WEBPACK_IMPORTED_MODULE_2__[\"AspectRatioChooser\"]);\ndefineWindowGlobal('NoahDiv', _components_noah_div__WEBPACK_IMPORTED_MODULE_3__[\"NoahDiv\"]);\n\n\n//# sourceURL=webpack:///./app/assets/javascripts/webpack/index.ts?");

/***/ }),

/***/ 0:
/*!*******************************************************!*\
  !*** multi ./app/assets/javascripts/webpack/index.ts ***!
  \*******************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

eval("module.exports = __webpack_require__(/*! ./app/assets/javascripts/webpack/index.ts */\"./app/assets/javascripts/webpack/index.ts\");\n\n\n//# sourceURL=webpack:///multi_./app/assets/javascripts/webpack/index.ts?");

/***/ }),

/***/ "react":
/*!************************!*\
  !*** external "React" ***!
  \************************/
/*! no static exports found */
/***/ (function(module, exports) {

eval("module.exports = React;\n\n//# sourceURL=webpack:///external_%22React%22?");

/***/ }),

/***/ "react-dom":
/*!***************************!*\
  !*** external "ReactDOM" ***!
  \***************************/
/*! no static exports found */
/***/ (function(module, exports) {

eval("module.exports = ReactDOM;\n\n//# sourceURL=webpack:///external_%22ReactDOM%22?");

/***/ })

/******/ });