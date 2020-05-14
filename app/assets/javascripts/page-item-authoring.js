(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("React"), require("ReactDOM"));
	else if(typeof define === 'function' && define.amd)
		define(["React", "ReactDOM"], factory);
	else {
		var a = typeof exports === 'object' ? factory(require("React"), require("ReactDOM")) : factory(root["React"], root["ReactDOM"]);
		for(var i in a) (typeof exports === 'object' ? exports : root)[i] = a[i];
	}
})(window, function(__WEBPACK_EXTERNAL_MODULE_react__, __WEBPACK_EXTERNAL_MODULE_react_dom__) {
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
/******/ 	return __webpack_require__(__webpack_require__.s = "./src/page-item-authoring/index.tsx");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./node_modules/@babel/runtime/helpers/inheritsLoose.js":
/*!**************************************************************!*\
  !*** ./node_modules/@babel/runtime/helpers/inheritsLoose.js ***!
  \**************************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

function _inheritsLoose(subClass, superClass) {
  subClass.prototype = Object.create(superClass.prototype);
  subClass.prototype.constructor = subClass;
  subClass.__proto__ = superClass;
}

module.exports = _inheritsLoose;

/***/ }),

/***/ "./node_modules/@emotion/cache/dist/cache.browser.esm.js":
/*!***************************************************************!*\
  !*** ./node_modules/@emotion/cache/dist/cache.browser.esm.js ***!
  \***************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _emotion_sheet__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @emotion/sheet */ "./node_modules/@emotion/sheet/dist/sheet.browser.esm.js");
/* harmony import */ var _emotion_stylis__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @emotion/stylis */ "./node_modules/@emotion/stylis/dist/stylis.browser.esm.js");
/* harmony import */ var _emotion_weak_memoize__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @emotion/weak-memoize */ "./node_modules/@emotion/weak-memoize/dist/weak-memoize.browser.esm.js");




// https://github.com/thysultan/stylis.js/tree/master/plugins/rule-sheet
// inlined to avoid umd wrapper and peerDep warnings/installing stylis
// since we use stylis after closure compiler
var delimiter = '/*|*/';
var needle = delimiter + '}';

function toSheet(block) {
  if (block) {
    Sheet.current.insert(block + '}');
  }
}

var Sheet = {
  current: null
};
var ruleSheet = function ruleSheet(context, content, selectors, parents, line, column, length, ns, depth, at) {
  switch (context) {
    // property
    case 1:
      {
        switch (content.charCodeAt(0)) {
          case 64:
            {
              // @import
              Sheet.current.insert(content + ';');
              return '';
            }
          // charcode for l

          case 108:
            {
              // charcode for b
              // this ignores label
              if (content.charCodeAt(2) === 98) {
                return '';
              }
            }
        }

        break;
      }
    // selector

    case 2:
      {
        if (ns === 0) return content + delimiter;
        break;
      }
    // at-rule

    case 3:
      {
        switch (ns) {
          // @font-face, @page
          case 102:
          case 112:
            {
              Sheet.current.insert(selectors[0] + content);
              return '';
            }

          default:
            {
              return content + (at === 0 ? delimiter : '');
            }
        }
      }

    case -2:
      {
        content.split(needle).forEach(toSheet);
      }
  }
};

var createCache = function createCache(options) {
  if (options === undefined) options = {};
  var key = options.key || 'css';
  var stylisOptions;

  if (options.prefix !== undefined) {
    stylisOptions = {
      prefix: options.prefix
    };
  }

  var stylis = new _emotion_stylis__WEBPACK_IMPORTED_MODULE_1__["default"](stylisOptions);

  if (true) {
    // $FlowFixMe
    if (/[^a-z-]/.test(key)) {
      throw new Error("Emotion key must only contain lower case alphabetical characters and - but \"" + key + "\" was passed");
    }
  }

  var inserted = {}; // $FlowFixMe

  var container;

  {
    container = options.container || document.head;
    var nodes = document.querySelectorAll("style[data-emotion-" + key + "]");
    Array.prototype.forEach.call(nodes, function (node) {
      var attrib = node.getAttribute("data-emotion-" + key); // $FlowFixMe

      attrib.split(' ').forEach(function (id) {
        inserted[id] = true;
      });

      if (node.parentNode !== container) {
        container.appendChild(node);
      }
    });
  }

  var _insert;

  {
    stylis.use(options.stylisPlugins)(ruleSheet);

    _insert = function insert(selector, serialized, sheet, shouldCache) {
      var name = serialized.name;
      Sheet.current = sheet;

      if ( true && serialized.map !== undefined) {
        var map = serialized.map;
        Sheet.current = {
          insert: function insert(rule) {
            sheet.insert(rule + map);
          }
        };
      }

      stylis(selector, serialized.styles);

      if (shouldCache) {
        cache.inserted[name] = true;
      }
    };
  }

  if (true) {
    // https://esbench.com/bench/5bf7371a4cd7e6009ef61d0a
    var commentStart = /\/\*/g;
    var commentEnd = /\*\//g;
    stylis.use(function (context, content) {
      switch (context) {
        case -1:
          {
            while (commentStart.test(content)) {
              commentEnd.lastIndex = commentStart.lastIndex;

              if (commentEnd.test(content)) {
                commentStart.lastIndex = commentEnd.lastIndex;
                continue;
              }

              throw new Error('Your styles have an unterminated comment ("/*" without corresponding "*/").');
            }

            commentStart.lastIndex = 0;
            break;
          }
      }
    });
    stylis.use(function (context, content, selectors) {
      switch (context) {
        case -1:
          {
            var flag = 'emotion-disable-server-rendering-unsafe-selector-warning-please-do-not-use-this-the-warning-exists-for-a-reason';
            var unsafePseudoClasses = content.match(/(:first|:nth|:nth-last)-child/g);

            if (unsafePseudoClasses && cache.compat !== true) {
              unsafePseudoClasses.forEach(function (unsafePseudoClass) {
                var ignoreRegExp = new RegExp(unsafePseudoClass + ".*\\/\\* " + flag + " \\*\\/");
                var ignore = ignoreRegExp.test(content);

                if (unsafePseudoClass && !ignore) {
                  console.error("The pseudo class \"" + unsafePseudoClass + "\" is potentially unsafe when doing server-side rendering. Try changing it to \"" + unsafePseudoClass.split('-child')[0] + "-of-type\".");
                }
              });
            }

            break;
          }
      }
    });
  }

  var cache = {
    key: key,
    sheet: new _emotion_sheet__WEBPACK_IMPORTED_MODULE_0__["StyleSheet"]({
      key: key,
      container: container,
      nonce: options.nonce,
      speedy: options.speedy
    }),
    nonce: options.nonce,
    inserted: inserted,
    registered: {},
    insert: _insert
  };
  return cache;
};

/* harmony default export */ __webpack_exports__["default"] = (createCache);


/***/ }),

/***/ "./node_modules/@emotion/core/dist/core.browser.esm.js":
/*!*************************************************************!*\
  !*** ./node_modules/@emotion/core/dist/core.browser.esm.js ***!
  \*************************************************************/
/*! exports provided: css, CacheProvider, ClassNames, Global, ThemeContext, jsx, keyframes, withEmotionCache */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "CacheProvider", function() { return CacheProvider; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ClassNames", function() { return ClassNames; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "Global", function() { return Global; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ThemeContext", function() { return ThemeContext; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "jsx", function() { return jsx; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "keyframes", function() { return keyframes; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "withEmotionCache", function() { return withEmotionCache; });
/* harmony import */ var _babel_runtime_helpers_inheritsLoose__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @babel/runtime/helpers/inheritsLoose */ "./node_modules/@babel/runtime/helpers/inheritsLoose.js");
/* harmony import */ var _babel_runtime_helpers_inheritsLoose__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_babel_runtime_helpers_inheritsLoose__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _emotion_cache__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @emotion/cache */ "./node_modules/@emotion/cache/dist/cache.browser.esm.js");
/* harmony import */ var _emotion_utils__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @emotion/utils */ "./node_modules/@emotion/utils/dist/utils.browser.esm.js");
/* harmony import */ var _emotion_serialize__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! @emotion/serialize */ "./node_modules/@emotion/serialize/dist/serialize.browser.esm.js");
/* harmony import */ var _emotion_sheet__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! @emotion/sheet */ "./node_modules/@emotion/sheet/dist/sheet.browser.esm.js");
/* harmony import */ var _emotion_css__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! @emotion/css */ "./node_modules/@emotion/css/dist/css.browser.esm.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "css", function() { return _emotion_css__WEBPACK_IMPORTED_MODULE_6__["default"]; });










var EmotionCacheContext = Object(react__WEBPACK_IMPORTED_MODULE_1__["createContext"])( // we're doing this to avoid preconstruct's dead code elimination in this one case
// because this module is primarily intended for the browser and node
// but it's also required in react native and similar environments sometimes
// and we could have a special build just for that
// but this is much easier and the native packages
// might use a different theme context in the future anyway
typeof HTMLElement !== 'undefined' ? Object(_emotion_cache__WEBPACK_IMPORTED_MODULE_2__["default"])() : null);
var ThemeContext = Object(react__WEBPACK_IMPORTED_MODULE_1__["createContext"])({});
var CacheProvider = EmotionCacheContext.Provider;

var withEmotionCache = function withEmotionCache(func) {
  var render = function render(props, ref) {
    return Object(react__WEBPACK_IMPORTED_MODULE_1__["createElement"])(EmotionCacheContext.Consumer, null, function (cache) {
      return func(props, cache, ref);
    });
  }; // $FlowFixMe


  return Object(react__WEBPACK_IMPORTED_MODULE_1__["forwardRef"])(render);
};

// thus we only need to replace what is a valid character for JS, but not for CSS

var sanitizeIdentifier = function sanitizeIdentifier(identifier) {
  return identifier.replace(/\$/g, '-');
};

var typePropName = '__EMOTION_TYPE_PLEASE_DO_NOT_USE__';
var labelPropName = '__EMOTION_LABEL_PLEASE_DO_NOT_USE__';
var hasOwnProperty = Object.prototype.hasOwnProperty;

var render = function render(cache, props, theme, ref) {
  var cssProp = theme === null ? props.css : props.css(theme); // so that using `css` from `emotion` and passing the result to the css prop works
  // not passing the registered cache to serializeStyles because it would
  // make certain babel optimisations not possible

  if (typeof cssProp === 'string' && cache.registered[cssProp] !== undefined) {
    cssProp = cache.registered[cssProp];
  }

  var type = props[typePropName];
  var registeredStyles = [cssProp];
  var className = '';

  if (typeof props.className === 'string') {
    className = Object(_emotion_utils__WEBPACK_IMPORTED_MODULE_3__["getRegisteredStyles"])(cache.registered, registeredStyles, props.className);
  } else if (props.className != null) {
    className = props.className + " ";
  }

  var serialized = Object(_emotion_serialize__WEBPACK_IMPORTED_MODULE_4__["serializeStyles"])(registeredStyles);

  if ( true && serialized.name.indexOf('-') === -1) {
    var labelFromStack = props[labelPropName];

    if (labelFromStack) {
      serialized = Object(_emotion_serialize__WEBPACK_IMPORTED_MODULE_4__["serializeStyles"])([serialized, 'label:' + labelFromStack + ';']);
    }
  }

  var rules = Object(_emotion_utils__WEBPACK_IMPORTED_MODULE_3__["insertStyles"])(cache, serialized, typeof type === 'string');
  className += cache.key + "-" + serialized.name;
  var newProps = {};

  for (var key in props) {
    if (hasOwnProperty.call(props, key) && key !== 'css' && key !== typePropName && ( false || key !== labelPropName)) {
      newProps[key] = props[key];
    }
  }

  newProps.ref = ref;
  newProps.className = className;
  var ele = Object(react__WEBPACK_IMPORTED_MODULE_1__["createElement"])(type, newProps);

  return ele;
};

var Emotion =
/* #__PURE__ */
withEmotionCache(function (props, cache, ref) {
  // use Context.read for the theme when it's stable
  if (typeof props.css === 'function') {
    return Object(react__WEBPACK_IMPORTED_MODULE_1__["createElement"])(ThemeContext.Consumer, null, function (theme) {
      return render(cache, props, theme, ref);
    });
  }

  return render(cache, props, null, ref);
});

if (true) {
  Emotion.displayName = 'EmotionCssPropInternal';
} // $FlowFixMe


var jsx = function jsx(type, props) {
  var args = arguments;

  if (props == null || !hasOwnProperty.call(props, 'css')) {
    // $FlowFixMe
    return react__WEBPACK_IMPORTED_MODULE_1__["createElement"].apply(undefined, args);
  }

  if ( true && typeof props.css === 'string' && // check if there is a css declaration
  props.css.indexOf(':') !== -1) {
    throw new Error("Strings are not allowed as css prop values, please wrap it in a css template literal from '@emotion/css' like this: css`" + props.css + "`");
  }

  var argsLength = args.length;
  var createElementArgArray = new Array(argsLength);
  createElementArgArray[0] = Emotion;
  var newProps = {};

  for (var key in props) {
    if (hasOwnProperty.call(props, key)) {
      newProps[key] = props[key];
    }
  }

  newProps[typePropName] = type;

  if (true) {
    var error = new Error();

    if (error.stack) {
      // chrome
      var match = error.stack.match(/at (?:Object\.|)jsx.*\n\s+at ([A-Z][A-Za-z$]+) /);

      if (!match) {
        // safari and firefox
        match = error.stack.match(/.*\n([A-Z][A-Za-z$]+)@/);
      }

      if (match) {
        newProps[labelPropName] = sanitizeIdentifier(match[1]);
      }
    }
  }

  createElementArgArray[1] = newProps;

  for (var i = 2; i < argsLength; i++) {
    createElementArgArray[i] = args[i];
  } // $FlowFixMe


  return react__WEBPACK_IMPORTED_MODULE_1__["createElement"].apply(null, createElementArgArray);
};

var warnedAboutCssPropForGlobal = false;
var Global =
/* #__PURE__ */
withEmotionCache(function (props, cache) {
  if ( true && !warnedAboutCssPropForGlobal && ( // check for className as well since the user is
  // probably using the custom createElement which
  // means it will be turned into a className prop
  // $FlowFixMe I don't really want to add it to the type since it shouldn't be used
  props.className || props.css)) {
    console.error("It looks like you're using the css prop on Global, did you mean to use the styles prop instead?");
    warnedAboutCssPropForGlobal = true;
  }

  var styles = props.styles;

  if (typeof styles === 'function') {
    return Object(react__WEBPACK_IMPORTED_MODULE_1__["createElement"])(ThemeContext.Consumer, null, function (theme) {
      var serialized = Object(_emotion_serialize__WEBPACK_IMPORTED_MODULE_4__["serializeStyles"])([styles(theme)]);
      return Object(react__WEBPACK_IMPORTED_MODULE_1__["createElement"])(InnerGlobal, {
        serialized: serialized,
        cache: cache
      });
    });
  }

  var serialized = Object(_emotion_serialize__WEBPACK_IMPORTED_MODULE_4__["serializeStyles"])([styles]);
  return Object(react__WEBPACK_IMPORTED_MODULE_1__["createElement"])(InnerGlobal, {
    serialized: serialized,
    cache: cache
  });
});

// maintain place over rerenders.
// initial render from browser, insertBefore context.sheet.tags[0] or if a style hasn't been inserted there yet, appendChild
// initial client-side render from SSR, use place of hydrating tag
var InnerGlobal =
/*#__PURE__*/
function (_React$Component) {
  _babel_runtime_helpers_inheritsLoose__WEBPACK_IMPORTED_MODULE_0___default()(InnerGlobal, _React$Component);

  function InnerGlobal(props, context, updater) {
    return _React$Component.call(this, props, context, updater) || this;
  }

  var _proto = InnerGlobal.prototype;

  _proto.componentDidMount = function componentDidMount() {
    this.sheet = new _emotion_sheet__WEBPACK_IMPORTED_MODULE_5__["StyleSheet"]({
      key: this.props.cache.key + "-global",
      nonce: this.props.cache.sheet.nonce,
      container: this.props.cache.sheet.container
    }); // $FlowFixMe

    var node = document.querySelector("style[data-emotion-" + this.props.cache.key + "=\"" + this.props.serialized.name + "\"]");

    if (node !== null) {
      this.sheet.tags.push(node);
    }

    if (this.props.cache.sheet.tags.length) {
      this.sheet.before = this.props.cache.sheet.tags[0];
    }

    this.insertStyles();
  };

  _proto.componentDidUpdate = function componentDidUpdate(prevProps) {
    if (prevProps.serialized.name !== this.props.serialized.name) {
      this.insertStyles();
    }
  };

  _proto.insertStyles = function insertStyles$1() {
    if (this.props.serialized.next !== undefined) {
      // insert keyframes
      Object(_emotion_utils__WEBPACK_IMPORTED_MODULE_3__["insertStyles"])(this.props.cache, this.props.serialized.next, true);
    }

    if (this.sheet.tags.length) {
      // if this doesn't exist then it will be null so the style element will be appended
      var element = this.sheet.tags[this.sheet.tags.length - 1].nextElementSibling;
      this.sheet.before = element;
      this.sheet.flush();
    }

    this.props.cache.insert("", this.props.serialized, this.sheet, false);
  };

  _proto.componentWillUnmount = function componentWillUnmount() {
    this.sheet.flush();
  };

  _proto.render = function render() {

    return null;
  };

  return InnerGlobal;
}(react__WEBPACK_IMPORTED_MODULE_1__["Component"]);

var keyframes = function keyframes() {
  var insertable = _emotion_css__WEBPACK_IMPORTED_MODULE_6__["default"].apply(void 0, arguments);
  var name = "animation-" + insertable.name; // $FlowFixMe

  return {
    name: name,
    styles: "@keyframes " + name + "{" + insertable.styles + "}",
    anim: 1,
    toString: function toString() {
      return "_EMO_" + this.name + "_" + this.styles + "_EMO_";
    }
  };
};

var classnames = function classnames(args) {
  var len = args.length;
  var i = 0;
  var cls = '';

  for (; i < len; i++) {
    var arg = args[i];
    if (arg == null) continue;
    var toAdd = void 0;

    switch (typeof arg) {
      case 'boolean':
        break;

      case 'object':
        {
          if (Array.isArray(arg)) {
            toAdd = classnames(arg);
          } else {
            toAdd = '';

            for (var k in arg) {
              if (arg[k] && k) {
                toAdd && (toAdd += ' ');
                toAdd += k;
              }
            }
          }

          break;
        }

      default:
        {
          toAdd = arg;
        }
    }

    if (toAdd) {
      cls && (cls += ' ');
      cls += toAdd;
    }
  }

  return cls;
};

function merge(registered, css, className) {
  var registeredStyles = [];
  var rawClassName = Object(_emotion_utils__WEBPACK_IMPORTED_MODULE_3__["getRegisteredStyles"])(registered, registeredStyles, className);

  if (registeredStyles.length < 2) {
    return className;
  }

  return rawClassName + css(registeredStyles);
}

var ClassNames = withEmotionCache(function (props, context) {
  return Object(react__WEBPACK_IMPORTED_MODULE_1__["createElement"])(ThemeContext.Consumer, null, function (theme) {
    var hasRendered = false;

    var css = function css() {
      if (hasRendered && "development" !== 'production') {
        throw new Error('css can only be used during render');
      }

      for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
        args[_key] = arguments[_key];
      }

      var serialized = Object(_emotion_serialize__WEBPACK_IMPORTED_MODULE_4__["serializeStyles"])(args, context.registered);

      {
        Object(_emotion_utils__WEBPACK_IMPORTED_MODULE_3__["insertStyles"])(context, serialized, false);
      }

      return context.key + "-" + serialized.name;
    };

    var cx = function cx() {
      if (hasRendered && "development" !== 'production') {
        throw new Error('cx can only be used during render');
      }

      for (var _len2 = arguments.length, args = new Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
        args[_key2] = arguments[_key2];
      }

      return merge(context.registered, css, classnames(args));
    };

    var content = {
      css: css,
      cx: cx,
      theme: theme
    };
    var ele = props.children(content);
    hasRendered = true;

    return ele;
  });
});




/***/ }),

/***/ "./node_modules/@emotion/css/dist/css.browser.esm.js":
/*!***********************************************************!*\
  !*** ./node_modules/@emotion/css/dist/css.browser.esm.js ***!
  \***********************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _emotion_serialize__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @emotion/serialize */ "./node_modules/@emotion/serialize/dist/serialize.browser.esm.js");


function css() {
  for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
    args[_key] = arguments[_key];
  }

  return Object(_emotion_serialize__WEBPACK_IMPORTED_MODULE_0__["serializeStyles"])(args);
}

/* harmony default export */ __webpack_exports__["default"] = (css);


/***/ }),

/***/ "./node_modules/@emotion/hash/dist/hash.browser.esm.js":
/*!*************************************************************!*\
  !*** ./node_modules/@emotion/hash/dist/hash.browser.esm.js ***!
  \*************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* eslint-disable */
// Inspired by https://github.com/garycourt/murmurhash-js
// Ported from https://github.com/aappleby/smhasher/blob/61a0530f28277f2e850bfc39600ce61d02b518de/src/MurmurHash2.cpp#L37-L86
function murmur2(str) {
  // 'm' and 'r' are mixing constants generated offline.
  // They're not really 'magic', they just happen to work well.
  // const m = 0x5bd1e995;
  // const r = 24;
  // Initialize the hash
  var h = 0; // Mix 4 bytes at a time into the hash

  var k,
      i = 0,
      len = str.length;

  for (; len >= 4; ++i, len -= 4) {
    k = str.charCodeAt(i) & 0xff | (str.charCodeAt(++i) & 0xff) << 8 | (str.charCodeAt(++i) & 0xff) << 16 | (str.charCodeAt(++i) & 0xff) << 24;
    k =
    /* Math.imul(k, m): */
    (k & 0xffff) * 0x5bd1e995 + ((k >>> 16) * 0xe995 << 16);
    k ^=
    /* k >>> r: */
    k >>> 24;
    h =
    /* Math.imul(k, m): */
    (k & 0xffff) * 0x5bd1e995 + ((k >>> 16) * 0xe995 << 16) ^
    /* Math.imul(h, m): */
    (h & 0xffff) * 0x5bd1e995 + ((h >>> 16) * 0xe995 << 16);
  } // Handle the last few bytes of the input array


  switch (len) {
    case 3:
      h ^= (str.charCodeAt(i + 2) & 0xff) << 16;

    case 2:
      h ^= (str.charCodeAt(i + 1) & 0xff) << 8;

    case 1:
      h ^= str.charCodeAt(i) & 0xff;
      h =
      /* Math.imul(h, m): */
      (h & 0xffff) * 0x5bd1e995 + ((h >>> 16) * 0xe995 << 16);
  } // Do a few final mixes of the hash to ensure the last few
  // bytes are well-incorporated.


  h ^= h >>> 13;
  h =
  /* Math.imul(h, m): */
  (h & 0xffff) * 0x5bd1e995 + ((h >>> 16) * 0xe995 << 16);
  return ((h ^ h >>> 15) >>> 0).toString(36);
}

/* harmony default export */ __webpack_exports__["default"] = (murmur2);


/***/ }),

/***/ "./node_modules/@emotion/memoize/dist/memoize.browser.esm.js":
/*!*******************************************************************!*\
  !*** ./node_modules/@emotion/memoize/dist/memoize.browser.esm.js ***!
  \*******************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
function memoize(fn) {
  var cache = {};
  return function (arg) {
    if (cache[arg] === undefined) cache[arg] = fn(arg);
    return cache[arg];
  };
}

/* harmony default export */ __webpack_exports__["default"] = (memoize);


/***/ }),

/***/ "./node_modules/@emotion/serialize/dist/serialize.browser.esm.js":
/*!***********************************************************************!*\
  !*** ./node_modules/@emotion/serialize/dist/serialize.browser.esm.js ***!
  \***********************************************************************/
/*! exports provided: serializeStyles */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "serializeStyles", function() { return serializeStyles; });
/* harmony import */ var _emotion_hash__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @emotion/hash */ "./node_modules/@emotion/hash/dist/hash.browser.esm.js");
/* harmony import */ var _emotion_unitless__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @emotion/unitless */ "./node_modules/@emotion/unitless/dist/unitless.browser.esm.js");
/* harmony import */ var _emotion_memoize__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @emotion/memoize */ "./node_modules/@emotion/memoize/dist/memoize.browser.esm.js");




var ILLEGAL_ESCAPE_SEQUENCE_ERROR = "You have illegal escape sequence in your template literal, most likely inside content's property value.\nBecause you write your CSS inside a JavaScript string you actually have to do double escaping, so for example \"content: '\\00d7';\" should become \"content: '\\\\00d7';\".\nYou can read more about this here:\nhttps://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals#ES2018_revision_of_illegal_escape_sequences";
var UNDEFINED_AS_OBJECT_KEY_ERROR = "You have passed in falsy value as style object's key (can happen when in example you pass unexported component as computed key).";
var hyphenateRegex = /[A-Z]|^ms/g;
var animationRegex = /_EMO_([^_]+?)_([^]*?)_EMO_/g;

var isCustomProperty = function isCustomProperty(property) {
  return property.charCodeAt(1) === 45;
};

var isProcessableValue = function isProcessableValue(value) {
  return value != null && typeof value !== 'boolean';
};

var processStyleName = Object(_emotion_memoize__WEBPACK_IMPORTED_MODULE_2__["default"])(function (styleName) {
  return isCustomProperty(styleName) ? styleName : styleName.replace(hyphenateRegex, '-$&').toLowerCase();
});

var processStyleValue = function processStyleValue(key, value) {
  switch (key) {
    case 'animation':
    case 'animationName':
      {
        if (typeof value === 'string') {
          return value.replace(animationRegex, function (match, p1, p2) {
            cursor = {
              name: p1,
              styles: p2,
              next: cursor
            };
            return p1;
          });
        }
      }
  }

  if (_emotion_unitless__WEBPACK_IMPORTED_MODULE_1__["default"][key] !== 1 && !isCustomProperty(key) && typeof value === 'number' && value !== 0) {
    return value + 'px';
  }

  return value;
};

if (true) {
  var contentValuePattern = /(attr|calc|counters?|url)\(/;
  var contentValues = ['normal', 'none', 'counter', 'open-quote', 'close-quote', 'no-open-quote', 'no-close-quote', 'initial', 'inherit', 'unset'];
  var oldProcessStyleValue = processStyleValue;
  var msPattern = /^-ms-/;
  var hyphenPattern = /-(.)/g;
  var hyphenatedCache = {};

  processStyleValue = function processStyleValue(key, value) {
    if (key === 'content') {
      if (typeof value !== 'string' || contentValues.indexOf(value) === -1 && !contentValuePattern.test(value) && (value.charAt(0) !== value.charAt(value.length - 1) || value.charAt(0) !== '"' && value.charAt(0) !== "'")) {
        console.error("You seem to be using a value for 'content' without quotes, try replacing it with `content: '\"" + value + "\"'`");
      }
    }

    var processed = oldProcessStyleValue(key, value);

    if (processed !== '' && !isCustomProperty(key) && key.indexOf('-') !== -1 && hyphenatedCache[key] === undefined) {
      hyphenatedCache[key] = true;
      console.error("Using kebab-case for css properties in objects is not supported. Did you mean " + key.replace(msPattern, 'ms-').replace(hyphenPattern, function (str, _char) {
        return _char.toUpperCase();
      }) + "?");
    }

    return processed;
  };
}

var shouldWarnAboutInterpolatingClassNameFromCss = true;

function handleInterpolation(mergedProps, registered, interpolation, couldBeSelectorInterpolation) {
  if (interpolation == null) {
    return '';
  }

  if (interpolation.__emotion_styles !== undefined) {
    if ( true && interpolation.toString() === 'NO_COMPONENT_SELECTOR') {
      throw new Error('Component selectors can only be used in conjunction with babel-plugin-emotion.');
    }

    return interpolation;
  }

  switch (typeof interpolation) {
    case 'boolean':
      {
        return '';
      }

    case 'object':
      {
        if (interpolation.anim === 1) {
          cursor = {
            name: interpolation.name,
            styles: interpolation.styles,
            next: cursor
          };
          return interpolation.name;
        }

        if (interpolation.styles !== undefined) {
          var next = interpolation.next;

          if (next !== undefined) {
            // not the most efficient thing ever but this is a pretty rare case
            // and there will be very few iterations of this generally
            while (next !== undefined) {
              cursor = {
                name: next.name,
                styles: next.styles,
                next: cursor
              };
              next = next.next;
            }
          }

          var styles = interpolation.styles + ";";

          if ( true && interpolation.map !== undefined) {
            styles += interpolation.map;
          }

          return styles;
        }

        return createStringFromObject(mergedProps, registered, interpolation);
      }

    case 'function':
      {
        if (mergedProps !== undefined) {
          var previousCursor = cursor;
          var result = interpolation(mergedProps);
          cursor = previousCursor;
          return handleInterpolation(mergedProps, registered, result, couldBeSelectorInterpolation);
        } else if (true) {
          console.error('Functions that are interpolated in css calls will be stringified.\n' + 'If you want to have a css call based on props, create a function that returns a css call like this\n' + 'let dynamicStyle = (props) => css`color: ${props.color}`\n' + 'It can be called directly with props or interpolated in a styled call like this\n' + "let SomeComponent = styled('div')`${dynamicStyle}`");
        }

        break;
      }

    case 'string':
      if (true) {
        var matched = [];
        var replaced = interpolation.replace(animationRegex, function (match, p1, p2) {
          var fakeVarName = "animation" + matched.length;
          matched.push("const " + fakeVarName + " = keyframes`" + p2.replace(/^@keyframes animation-\w+/, '') + "`");
          return "${" + fakeVarName + "}";
        });

        if (matched.length) {
          console.error('`keyframes` output got interpolated into plain string, please wrap it with `css`.\n\n' + 'Instead of doing this:\n\n' + [].concat(matched, ["`" + replaced + "`"]).join('\n') + '\n\nYou should wrap it with `css` like this:\n\n' + ("css`" + replaced + "`"));
        }
      }

      break;
  } // finalize string values (regular strings and functions interpolated into css calls)


  if (registered == null) {
    return interpolation;
  }

  var cached = registered[interpolation];

  if ( true && couldBeSelectorInterpolation && shouldWarnAboutInterpolatingClassNameFromCss && cached !== undefined) {
    console.error('Interpolating a className from css`` is not recommended and will cause problems with composition.\n' + 'Interpolating a className from css`` will be completely unsupported in a future major version of Emotion');
    shouldWarnAboutInterpolatingClassNameFromCss = false;
  }

  return cached !== undefined && !couldBeSelectorInterpolation ? cached : interpolation;
}

function createStringFromObject(mergedProps, registered, obj) {
  var string = '';

  if (Array.isArray(obj)) {
    for (var i = 0; i < obj.length; i++) {
      string += handleInterpolation(mergedProps, registered, obj[i], false);
    }
  } else {
    for (var _key in obj) {
      var value = obj[_key];

      if (typeof value !== 'object') {
        if (registered != null && registered[value] !== undefined) {
          string += _key + "{" + registered[value] + "}";
        } else if (isProcessableValue(value)) {
          string += processStyleName(_key) + ":" + processStyleValue(_key, value) + ";";
        }
      } else {
        if (_key === 'NO_COMPONENT_SELECTOR' && "development" !== 'production') {
          throw new Error('Component selectors can only be used in conjunction with babel-plugin-emotion.');
        }

        if (Array.isArray(value) && typeof value[0] === 'string' && (registered == null || registered[value[0]] === undefined)) {
          for (var _i = 0; _i < value.length; _i++) {
            if (isProcessableValue(value[_i])) {
              string += processStyleName(_key) + ":" + processStyleValue(_key, value[_i]) + ";";
            }
          }
        } else {
          var interpolated = handleInterpolation(mergedProps, registered, value, false);

          switch (_key) {
            case 'animation':
            case 'animationName':
              {
                string += processStyleName(_key) + ":" + interpolated + ";";
                break;
              }

            default:
              {
                if ( true && _key === 'undefined') {
                  console.error(UNDEFINED_AS_OBJECT_KEY_ERROR);
                }

                string += _key + "{" + interpolated + "}";
              }
          }
        }
      }
    }
  }

  return string;
}

var labelPattern = /label:\s*([^\s;\n{]+)\s*;/g;
var sourceMapPattern;

if (true) {
  sourceMapPattern = /\/\*#\ssourceMappingURL=data:application\/json;\S+\s+\*\//;
} // this is the cursor for keyframes
// keyframes are stored on the SerializedStyles object as a linked list


var cursor;
var serializeStyles = function serializeStyles(args, registered, mergedProps) {
  if (args.length === 1 && typeof args[0] === 'object' && args[0] !== null && args[0].styles !== undefined) {
    return args[0];
  }

  var stringMode = true;
  var styles = '';
  cursor = undefined;
  var strings = args[0];

  if (strings == null || strings.raw === undefined) {
    stringMode = false;
    styles += handleInterpolation(mergedProps, registered, strings, false);
  } else {
    if ( true && strings[0] === undefined) {
      console.error(ILLEGAL_ESCAPE_SEQUENCE_ERROR);
    }

    styles += strings[0];
  } // we start at 1 since we've already handled the first arg


  for (var i = 1; i < args.length; i++) {
    styles += handleInterpolation(mergedProps, registered, args[i], styles.charCodeAt(styles.length - 1) === 46);

    if (stringMode) {
      if ( true && strings[i] === undefined) {
        console.error(ILLEGAL_ESCAPE_SEQUENCE_ERROR);
      }

      styles += strings[i];
    }
  }

  var sourceMap;

  if (true) {
    styles = styles.replace(sourceMapPattern, function (match) {
      sourceMap = match;
      return '';
    });
  } // using a global regex with .exec is stateful so lastIndex has to be reset each time


  labelPattern.lastIndex = 0;
  var identifierName = '';
  var match; // https://esbench.com/bench/5b809c2cf2949800a0f61fb5

  while ((match = labelPattern.exec(styles)) !== null) {
    identifierName += '-' + // $FlowFixMe we know it's not null
    match[1];
  }

  var name = Object(_emotion_hash__WEBPACK_IMPORTED_MODULE_0__["default"])(styles) + identifierName;

  if (true) {
    // $FlowFixMe SerializedStyles type doesn't have toString property (and we don't want to add it)
    return {
      name: name,
      styles: styles,
      map: sourceMap,
      next: cursor,
      toString: function toString() {
        return "You have tried to stringify object returned from `css` function. It isn't supposed to be used directly (e.g. as value of the `className` prop), but rather handed to emotion so it can handle it (e.g. as value of `css` prop).";
      }
    };
  }

  return {
    name: name,
    styles: styles,
    next: cursor
  };
};




/***/ }),

/***/ "./node_modules/@emotion/sheet/dist/sheet.browser.esm.js":
/*!***************************************************************!*\
  !*** ./node_modules/@emotion/sheet/dist/sheet.browser.esm.js ***!
  \***************************************************************/
/*! exports provided: StyleSheet */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "StyleSheet", function() { return StyleSheet; });
/*

Based off glamor's StyleSheet, thanks Sunil ❤️

high performance StyleSheet for css-in-js systems

- uses multiple style tags behind the scenes for millions of rules
- uses `insertRule` for appending in production for *much* faster performance

// usage

import { StyleSheet } from '@emotion/sheet'

let styleSheet = new StyleSheet({ key: '', container: document.head })

styleSheet.insert('#box { border: 1px solid red; }')
- appends a css rule into the stylesheet

styleSheet.flush()
- empties the stylesheet of all its contents

*/
// $FlowFixMe
function sheetForTag(tag) {
  if (tag.sheet) {
    // $FlowFixMe
    return tag.sheet;
  } // this weirdness brought to you by firefox

  /* istanbul ignore next */


  for (var i = 0; i < document.styleSheets.length; i++) {
    if (document.styleSheets[i].ownerNode === tag) {
      // $FlowFixMe
      return document.styleSheets[i];
    }
  }
}

function createStyleElement(options) {
  var tag = document.createElement('style');
  tag.setAttribute('data-emotion', options.key);

  if (options.nonce !== undefined) {
    tag.setAttribute('nonce', options.nonce);
  }

  tag.appendChild(document.createTextNode(''));
  return tag;
}

var StyleSheet =
/*#__PURE__*/
function () {
  function StyleSheet(options) {
    this.isSpeedy = options.speedy === undefined ? "development" === 'production' : options.speedy;
    this.tags = [];
    this.ctr = 0;
    this.nonce = options.nonce; // key is the value of the data-emotion attribute, it's used to identify different sheets

    this.key = options.key;
    this.container = options.container;
    this.before = null;
  }

  var _proto = StyleSheet.prototype;

  _proto.insert = function insert(rule) {
    // the max length is how many rules we have per style tag, it's 65000 in speedy mode
    // it's 1 in dev because we insert source maps that map a single rule to a location
    // and you can only have one source map per style tag
    if (this.ctr % (this.isSpeedy ? 65000 : 1) === 0) {
      var _tag = createStyleElement(this);

      var before;

      if (this.tags.length === 0) {
        before = this.before;
      } else {
        before = this.tags[this.tags.length - 1].nextSibling;
      }

      this.container.insertBefore(_tag, before);
      this.tags.push(_tag);
    }

    var tag = this.tags[this.tags.length - 1];

    if (this.isSpeedy) {
      var sheet = sheetForTag(tag);

      try {
        // this is a really hot path
        // we check the second character first because having "i"
        // as the second character will happen less often than
        // having "@" as the first character
        var isImportRule = rule.charCodeAt(1) === 105 && rule.charCodeAt(0) === 64; // this is the ultrafast version, works across browsers
        // the big drawback is that the css won't be editable in devtools

        sheet.insertRule(rule, // we need to insert @import rules before anything else
        // otherwise there will be an error
        // technically this means that the @import rules will
        // _usually_(not always since there could be multiple style tags)
        // be the first ones in prod and generally later in dev
        // this shouldn't really matter in the real world though
        // @import is generally only used for font faces from google fonts and etc.
        // so while this could be technically correct then it would be slower and larger
        // for a tiny bit of correctness that won't matter in the real world
        isImportRule ? 0 : sheet.cssRules.length);
      } catch (e) {
        if (true) {
          console.warn("There was a problem inserting the following rule: \"" + rule + "\"", e);
        }
      }
    } else {
      tag.appendChild(document.createTextNode(rule));
    }

    this.ctr++;
  };

  _proto.flush = function flush() {
    // $FlowFixMe
    this.tags.forEach(function (tag) {
      return tag.parentNode.removeChild(tag);
    });
    this.tags = [];
    this.ctr = 0;
  };

  return StyleSheet;
}();




/***/ }),

/***/ "./node_modules/@emotion/stylis/dist/stylis.browser.esm.js":
/*!*****************************************************************!*\
  !*** ./node_modules/@emotion/stylis/dist/stylis.browser.esm.js ***!
  \*****************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
function stylis_min (W) {
  function M(d, c, e, h, a) {
    for (var m = 0, b = 0, v = 0, n = 0, q, g, x = 0, K = 0, k, u = k = q = 0, l = 0, r = 0, I = 0, t = 0, B = e.length, J = B - 1, y, f = '', p = '', F = '', G = '', C; l < B;) {
      g = e.charCodeAt(l);
      l === J && 0 !== b + n + v + m && (0 !== b && (g = 47 === b ? 10 : 47), n = v = m = 0, B++, J++);

      if (0 === b + n + v + m) {
        if (l === J && (0 < r && (f = f.replace(N, '')), 0 < f.trim().length)) {
          switch (g) {
            case 32:
            case 9:
            case 59:
            case 13:
            case 10:
              break;

            default:
              f += e.charAt(l);
          }

          g = 59;
        }

        switch (g) {
          case 123:
            f = f.trim();
            q = f.charCodeAt(0);
            k = 1;

            for (t = ++l; l < B;) {
              switch (g = e.charCodeAt(l)) {
                case 123:
                  k++;
                  break;

                case 125:
                  k--;
                  break;

                case 47:
                  switch (g = e.charCodeAt(l + 1)) {
                    case 42:
                    case 47:
                      a: {
                        for (u = l + 1; u < J; ++u) {
                          switch (e.charCodeAt(u)) {
                            case 47:
                              if (42 === g && 42 === e.charCodeAt(u - 1) && l + 2 !== u) {
                                l = u + 1;
                                break a;
                              }

                              break;

                            case 10:
                              if (47 === g) {
                                l = u + 1;
                                break a;
                              }

                          }
                        }

                        l = u;
                      }

                  }

                  break;

                case 91:
                  g++;

                case 40:
                  g++;

                case 34:
                case 39:
                  for (; l++ < J && e.charCodeAt(l) !== g;) {
                  }

              }

              if (0 === k) break;
              l++;
            }

            k = e.substring(t, l);
            0 === q && (q = (f = f.replace(ca, '').trim()).charCodeAt(0));

            switch (q) {
              case 64:
                0 < r && (f = f.replace(N, ''));
                g = f.charCodeAt(1);

                switch (g) {
                  case 100:
                  case 109:
                  case 115:
                  case 45:
                    r = c;
                    break;

                  default:
                    r = O;
                }

                k = M(c, r, k, g, a + 1);
                t = k.length;
                0 < A && (r = X(O, f, I), C = H(3, k, r, c, D, z, t, g, a, h), f = r.join(''), void 0 !== C && 0 === (t = (k = C.trim()).length) && (g = 0, k = ''));
                if (0 < t) switch (g) {
                  case 115:
                    f = f.replace(da, ea);

                  case 100:
                  case 109:
                  case 45:
                    k = f + '{' + k + '}';
                    break;

                  case 107:
                    f = f.replace(fa, '$1 $2');
                    k = f + '{' + k + '}';
                    k = 1 === w || 2 === w && L('@' + k, 3) ? '@-webkit-' + k + '@' + k : '@' + k;
                    break;

                  default:
                    k = f + k, 112 === h && (k = (p += k, ''));
                } else k = '';
                break;

              default:
                k = M(c, X(c, f, I), k, h, a + 1);
            }

            F += k;
            k = I = r = u = q = 0;
            f = '';
            g = e.charCodeAt(++l);
            break;

          case 125:
          case 59:
            f = (0 < r ? f.replace(N, '') : f).trim();
            if (1 < (t = f.length)) switch (0 === u && (q = f.charCodeAt(0), 45 === q || 96 < q && 123 > q) && (t = (f = f.replace(' ', ':')).length), 0 < A && void 0 !== (C = H(1, f, c, d, D, z, p.length, h, a, h)) && 0 === (t = (f = C.trim()).length) && (f = '\x00\x00'), q = f.charCodeAt(0), g = f.charCodeAt(1), q) {
              case 0:
                break;

              case 64:
                if (105 === g || 99 === g) {
                  G += f + e.charAt(l);
                  break;
                }

              default:
                58 !== f.charCodeAt(t - 1) && (p += P(f, q, g, f.charCodeAt(2)));
            }
            I = r = u = q = 0;
            f = '';
            g = e.charCodeAt(++l);
        }
      }

      switch (g) {
        case 13:
        case 10:
          47 === b ? b = 0 : 0 === 1 + q && 107 !== h && 0 < f.length && (r = 1, f += '\x00');
          0 < A * Y && H(0, f, c, d, D, z, p.length, h, a, h);
          z = 1;
          D++;
          break;

        case 59:
        case 125:
          if (0 === b + n + v + m) {
            z++;
            break;
          }

        default:
          z++;
          y = e.charAt(l);

          switch (g) {
            case 9:
            case 32:
              if (0 === n + m + b) switch (x) {
                case 44:
                case 58:
                case 9:
                case 32:
                  y = '';
                  break;

                default:
                  32 !== g && (y = ' ');
              }
              break;

            case 0:
              y = '\\0';
              break;

            case 12:
              y = '\\f';
              break;

            case 11:
              y = '\\v';
              break;

            case 38:
              0 === n + b + m && (r = I = 1, y = '\f' + y);
              break;

            case 108:
              if (0 === n + b + m + E && 0 < u) switch (l - u) {
                case 2:
                  112 === x && 58 === e.charCodeAt(l - 3) && (E = x);

                case 8:
                  111 === K && (E = K);
              }
              break;

            case 58:
              0 === n + b + m && (u = l);
              break;

            case 44:
              0 === b + v + n + m && (r = 1, y += '\r');
              break;

            case 34:
            case 39:
              0 === b && (n = n === g ? 0 : 0 === n ? g : n);
              break;

            case 91:
              0 === n + b + v && m++;
              break;

            case 93:
              0 === n + b + v && m--;
              break;

            case 41:
              0 === n + b + m && v--;
              break;

            case 40:
              if (0 === n + b + m) {
                if (0 === q) switch (2 * x + 3 * K) {
                  case 533:
                    break;

                  default:
                    q = 1;
                }
                v++;
              }

              break;

            case 64:
              0 === b + v + n + m + u + k && (k = 1);
              break;

            case 42:
            case 47:
              if (!(0 < n + m + v)) switch (b) {
                case 0:
                  switch (2 * g + 3 * e.charCodeAt(l + 1)) {
                    case 235:
                      b = 47;
                      break;

                    case 220:
                      t = l, b = 42;
                  }

                  break;

                case 42:
                  47 === g && 42 === x && t + 2 !== l && (33 === e.charCodeAt(t + 2) && (p += e.substring(t, l + 1)), y = '', b = 0);
              }
          }

          0 === b && (f += y);
      }

      K = x;
      x = g;
      l++;
    }

    t = p.length;

    if (0 < t) {
      r = c;
      if (0 < A && (C = H(2, p, r, d, D, z, t, h, a, h), void 0 !== C && 0 === (p = C).length)) return G + p + F;
      p = r.join(',') + '{' + p + '}';

      if (0 !== w * E) {
        2 !== w || L(p, 2) || (E = 0);

        switch (E) {
          case 111:
            p = p.replace(ha, ':-moz-$1') + p;
            break;

          case 112:
            p = p.replace(Q, '::-webkit-input-$1') + p.replace(Q, '::-moz-$1') + p.replace(Q, ':-ms-input-$1') + p;
        }

        E = 0;
      }
    }

    return G + p + F;
  }

  function X(d, c, e) {
    var h = c.trim().split(ia);
    c = h;
    var a = h.length,
        m = d.length;

    switch (m) {
      case 0:
      case 1:
        var b = 0;

        for (d = 0 === m ? '' : d[0] + ' '; b < a; ++b) {
          c[b] = Z(d, c[b], e).trim();
        }

        break;

      default:
        var v = b = 0;

        for (c = []; b < a; ++b) {
          for (var n = 0; n < m; ++n) {
            c[v++] = Z(d[n] + ' ', h[b], e).trim();
          }
        }

    }

    return c;
  }

  function Z(d, c, e) {
    var h = c.charCodeAt(0);
    33 > h && (h = (c = c.trim()).charCodeAt(0));

    switch (h) {
      case 38:
        return c.replace(F, '$1' + d.trim());

      case 58:
        return d.trim() + c.replace(F, '$1' + d.trim());

      default:
        if (0 < 1 * e && 0 < c.indexOf('\f')) return c.replace(F, (58 === d.charCodeAt(0) ? '' : '$1') + d.trim());
    }

    return d + c;
  }

  function P(d, c, e, h) {
    var a = d + ';',
        m = 2 * c + 3 * e + 4 * h;

    if (944 === m) {
      d = a.indexOf(':', 9) + 1;
      var b = a.substring(d, a.length - 1).trim();
      b = a.substring(0, d).trim() + b + ';';
      return 1 === w || 2 === w && L(b, 1) ? '-webkit-' + b + b : b;
    }

    if (0 === w || 2 === w && !L(a, 1)) return a;

    switch (m) {
      case 1015:
        return 97 === a.charCodeAt(10) ? '-webkit-' + a + a : a;

      case 951:
        return 116 === a.charCodeAt(3) ? '-webkit-' + a + a : a;

      case 963:
        return 110 === a.charCodeAt(5) ? '-webkit-' + a + a : a;

      case 1009:
        if (100 !== a.charCodeAt(4)) break;

      case 969:
      case 942:
        return '-webkit-' + a + a;

      case 978:
        return '-webkit-' + a + '-moz-' + a + a;

      case 1019:
      case 983:
        return '-webkit-' + a + '-moz-' + a + '-ms-' + a + a;

      case 883:
        if (45 === a.charCodeAt(8)) return '-webkit-' + a + a;
        if (0 < a.indexOf('image-set(', 11)) return a.replace(ja, '$1-webkit-$2') + a;
        break;

      case 932:
        if (45 === a.charCodeAt(4)) switch (a.charCodeAt(5)) {
          case 103:
            return '-webkit-box-' + a.replace('-grow', '') + '-webkit-' + a + '-ms-' + a.replace('grow', 'positive') + a;

          case 115:
            return '-webkit-' + a + '-ms-' + a.replace('shrink', 'negative') + a;

          case 98:
            return '-webkit-' + a + '-ms-' + a.replace('basis', 'preferred-size') + a;
        }
        return '-webkit-' + a + '-ms-' + a + a;

      case 964:
        return '-webkit-' + a + '-ms-flex-' + a + a;

      case 1023:
        if (99 !== a.charCodeAt(8)) break;
        b = a.substring(a.indexOf(':', 15)).replace('flex-', '').replace('space-between', 'justify');
        return '-webkit-box-pack' + b + '-webkit-' + a + '-ms-flex-pack' + b + a;

      case 1005:
        return ka.test(a) ? a.replace(aa, ':-webkit-') + a.replace(aa, ':-moz-') + a : a;

      case 1e3:
        b = a.substring(13).trim();
        c = b.indexOf('-') + 1;

        switch (b.charCodeAt(0) + b.charCodeAt(c)) {
          case 226:
            b = a.replace(G, 'tb');
            break;

          case 232:
            b = a.replace(G, 'tb-rl');
            break;

          case 220:
            b = a.replace(G, 'lr');
            break;

          default:
            return a;
        }

        return '-webkit-' + a + '-ms-' + b + a;

      case 1017:
        if (-1 === a.indexOf('sticky', 9)) break;

      case 975:
        c = (a = d).length - 10;
        b = (33 === a.charCodeAt(c) ? a.substring(0, c) : a).substring(d.indexOf(':', 7) + 1).trim();

        switch (m = b.charCodeAt(0) + (b.charCodeAt(7) | 0)) {
          case 203:
            if (111 > b.charCodeAt(8)) break;

          case 115:
            a = a.replace(b, '-webkit-' + b) + ';' + a;
            break;

          case 207:
          case 102:
            a = a.replace(b, '-webkit-' + (102 < m ? 'inline-' : '') + 'box') + ';' + a.replace(b, '-webkit-' + b) + ';' + a.replace(b, '-ms-' + b + 'box') + ';' + a;
        }

        return a + ';';

      case 938:
        if (45 === a.charCodeAt(5)) switch (a.charCodeAt(6)) {
          case 105:
            return b = a.replace('-items', ''), '-webkit-' + a + '-webkit-box-' + b + '-ms-flex-' + b + a;

          case 115:
            return '-webkit-' + a + '-ms-flex-item-' + a.replace(ba, '') + a;

          default:
            return '-webkit-' + a + '-ms-flex-line-pack' + a.replace('align-content', '').replace(ba, '') + a;
        }
        break;

      case 973:
      case 989:
        if (45 !== a.charCodeAt(3) || 122 === a.charCodeAt(4)) break;

      case 931:
      case 953:
        if (!0 === la.test(d)) return 115 === (b = d.substring(d.indexOf(':') + 1)).charCodeAt(0) ? P(d.replace('stretch', 'fill-available'), c, e, h).replace(':fill-available', ':stretch') : a.replace(b, '-webkit-' + b) + a.replace(b, '-moz-' + b.replace('fill-', '')) + a;
        break;

      case 962:
        if (a = '-webkit-' + a + (102 === a.charCodeAt(5) ? '-ms-' + a : '') + a, 211 === e + h && 105 === a.charCodeAt(13) && 0 < a.indexOf('transform', 10)) return a.substring(0, a.indexOf(';', 27) + 1).replace(ma, '$1-webkit-$2') + a;
    }

    return a;
  }

  function L(d, c) {
    var e = d.indexOf(1 === c ? ':' : '{'),
        h = d.substring(0, 3 !== c ? e : 10);
    e = d.substring(e + 1, d.length - 1);
    return R(2 !== c ? h : h.replace(na, '$1'), e, c);
  }

  function ea(d, c) {
    var e = P(c, c.charCodeAt(0), c.charCodeAt(1), c.charCodeAt(2));
    return e !== c + ';' ? e.replace(oa, ' or ($1)').substring(4) : '(' + c + ')';
  }

  function H(d, c, e, h, a, m, b, v, n, q) {
    for (var g = 0, x = c, w; g < A; ++g) {
      switch (w = S[g].call(B, d, x, e, h, a, m, b, v, n, q)) {
        case void 0:
        case !1:
        case !0:
        case null:
          break;

        default:
          x = w;
      }
    }

    if (x !== c) return x;
  }

  function T(d) {
    switch (d) {
      case void 0:
      case null:
        A = S.length = 0;
        break;

      default:
        if ('function' === typeof d) S[A++] = d;else if ('object' === typeof d) for (var c = 0, e = d.length; c < e; ++c) {
          T(d[c]);
        } else Y = !!d | 0;
    }

    return T;
  }

  function U(d) {
    d = d.prefix;
    void 0 !== d && (R = null, d ? 'function' !== typeof d ? w = 1 : (w = 2, R = d) : w = 0);
    return U;
  }

  function B(d, c) {
    var e = d;
    33 > e.charCodeAt(0) && (e = e.trim());
    V = e;
    e = [V];

    if (0 < A) {
      var h = H(-1, c, e, e, D, z, 0, 0, 0, 0);
      void 0 !== h && 'string' === typeof h && (c = h);
    }

    var a = M(O, e, c, 0, 0);
    0 < A && (h = H(-2, a, e, e, D, z, a.length, 0, 0, 0), void 0 !== h && (a = h));
    V = '';
    E = 0;
    z = D = 1;
    return a;
  }

  var ca = /^\0+/g,
      N = /[\0\r\f]/g,
      aa = /: */g,
      ka = /zoo|gra/,
      ma = /([,: ])(transform)/g,
      ia = /,\r+?/g,
      F = /([\t\r\n ])*\f?&/g,
      fa = /@(k\w+)\s*(\S*)\s*/,
      Q = /::(place)/g,
      ha = /:(read-only)/g,
      G = /[svh]\w+-[tblr]{2}/,
      da = /\(\s*(.*)\s*\)/g,
      oa = /([\s\S]*?);/g,
      ba = /-self|flex-/g,
      na = /[^]*?(:[rp][el]a[\w-]+)[^]*/,
      la = /stretch|:\s*\w+\-(?:conte|avail)/,
      ja = /([^-])(image-set\()/,
      z = 1,
      D = 1,
      E = 0,
      w = 1,
      O = [],
      S = [],
      A = 0,
      R = null,
      Y = 0,
      V = '';
  B.use = T;
  B.set = U;
  void 0 !== W && U(W);
  return B;
}

/* harmony default export */ __webpack_exports__["default"] = (stylis_min);


/***/ }),

/***/ "./node_modules/@emotion/unitless/dist/unitless.browser.esm.js":
/*!*********************************************************************!*\
  !*** ./node_modules/@emotion/unitless/dist/unitless.browser.esm.js ***!
  \*********************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
var unitlessKeys = {
  animationIterationCount: 1,
  borderImageOutset: 1,
  borderImageSlice: 1,
  borderImageWidth: 1,
  boxFlex: 1,
  boxFlexGroup: 1,
  boxOrdinalGroup: 1,
  columnCount: 1,
  columns: 1,
  flex: 1,
  flexGrow: 1,
  flexPositive: 1,
  flexShrink: 1,
  flexNegative: 1,
  flexOrder: 1,
  gridRow: 1,
  gridRowEnd: 1,
  gridRowSpan: 1,
  gridRowStart: 1,
  gridColumn: 1,
  gridColumnEnd: 1,
  gridColumnSpan: 1,
  gridColumnStart: 1,
  msGridRow: 1,
  msGridRowSpan: 1,
  msGridColumn: 1,
  msGridColumnSpan: 1,
  fontWeight: 1,
  lineHeight: 1,
  opacity: 1,
  order: 1,
  orphans: 1,
  tabSize: 1,
  widows: 1,
  zIndex: 1,
  zoom: 1,
  WebkitLineClamp: 1,
  // SVG-related properties
  fillOpacity: 1,
  floodOpacity: 1,
  stopOpacity: 1,
  strokeDasharray: 1,
  strokeDashoffset: 1,
  strokeMiterlimit: 1,
  strokeOpacity: 1,
  strokeWidth: 1
};

/* harmony default export */ __webpack_exports__["default"] = (unitlessKeys);


/***/ }),

/***/ "./node_modules/@emotion/utils/dist/utils.browser.esm.js":
/*!***************************************************************!*\
  !*** ./node_modules/@emotion/utils/dist/utils.browser.esm.js ***!
  \***************************************************************/
/*! exports provided: getRegisteredStyles, insertStyles */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getRegisteredStyles", function() { return getRegisteredStyles; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "insertStyles", function() { return insertStyles; });
var isBrowser = "object" !== 'undefined';
function getRegisteredStyles(registered, registeredStyles, classNames) {
  var rawClassName = '';
  classNames.split(' ').forEach(function (className) {
    if (registered[className] !== undefined) {
      registeredStyles.push(registered[className]);
    } else {
      rawClassName += className + " ";
    }
  });
  return rawClassName;
}
var insertStyles = function insertStyles(cache, serialized, isStringTag) {
  var className = cache.key + "-" + serialized.name;

  if ( // we only need to add the styles to the registered cache if the
  // class name could be used further down
  // the tree but if it's a string tag, we know it won't
  // so we don't have to add it to registered cache.
  // this improves memory usage since we can avoid storing the whole style string
  (isStringTag === false || // we need to always store it if we're in compat mode and
  // in node since emotion-server relies on whether a style is in
  // the registered cache to know whether a style is global or not
  // also, note that this check will be dead code eliminated in the browser
  isBrowser === false && cache.compat !== undefined) && cache.registered[className] === undefined) {
    cache.registered[className] = serialized.styles;
  }

  if (cache.inserted[serialized.name] === undefined) {
    var current = serialized;

    do {
      var maybeStyles = cache.insert("." + className, current, cache.sheet, true);

      current = current.next;
    } while (current !== undefined);
  }
};




/***/ }),

/***/ "./node_modules/@emotion/weak-memoize/dist/weak-memoize.browser.esm.js":
/*!*****************************************************************************!*\
  !*** ./node_modules/@emotion/weak-memoize/dist/weak-memoize.browser.esm.js ***!
  \*****************************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
var weakMemoize = function weakMemoize(func) {
  // $FlowFixMe flow doesn't include all non-primitive types as allowed for weakmaps
  var cache = new WeakMap();
  return function (arg) {
    if (cache.has(arg)) {
      // $FlowFixMe
      return cache.get(arg);
    }

    var ret = func(arg);
    cache.set(arg, ret);
    return ret;
  };
};

/* harmony default export */ __webpack_exports__["default"] = (weakMemoize);


/***/ }),

/***/ "./node_modules/classnames/index.js":
/*!******************************************!*\
  !*** ./node_modules/classnames/index.js ***!
  \******************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var __WEBPACK_AMD_DEFINE_ARRAY__, __WEBPACK_AMD_DEFINE_RESULT__;/*!
  Copyright (c) 2017 Jed Watson.
  Licensed under the MIT License (MIT), see
  http://jedwatson.github.io/classnames
*/
/* global define */

(function () {
	'use strict';

	var hasOwn = {}.hasOwnProperty;

	function classNames () {
		var classes = [];

		for (var i = 0; i < arguments.length; i++) {
			var arg = arguments[i];
			if (!arg) continue;

			var argType = typeof arg;

			if (argType === 'string' || argType === 'number') {
				classes.push(arg);
			} else if (Array.isArray(arg) && arg.length) {
				var inner = classNames.apply(null, arg);
				if (inner) {
					classes.push(inner);
				}
			} else if (argType === 'object') {
				for (var key in arg) {
					if (hasOwn.call(arg, key) && arg[key]) {
						classes.push(key);
					}
				}
			}
		}

		return classes.join(' ');
	}

	if ( true && module.exports) {
		classNames.default = classNames;
		module.exports = classNames;
	} else if (true) {
		// register as 'classnames', consistent with npm package name
		!(__WEBPACK_AMD_DEFINE_ARRAY__ = [], __WEBPACK_AMD_DEFINE_RESULT__ = (function () {
			return classNames;
		}).apply(exports, __WEBPACK_AMD_DEFINE_ARRAY__),
				__WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__));
	} else {}
}());


/***/ }),

/***/ "./node_modules/memoize-one/dist/memoize-one.esm.js":
/*!**********************************************************!*\
  !*** ./node_modules/memoize-one/dist/memoize-one.esm.js ***!
  \**********************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
function areInputsEqual(newInputs, lastInputs) {
    if (newInputs.length !== lastInputs.length) {
        return false;
    }
    for (var i = 0; i < newInputs.length; i++) {
        if (newInputs[i] !== lastInputs[i]) {
            return false;
        }
    }
    return true;
}

function memoizeOne(resultFn, isEqual) {
    if (isEqual === void 0) { isEqual = areInputsEqual; }
    var lastThis;
    var lastArgs = [];
    var lastResult;
    var calledOnce = false;
    function memoized() {
        var newArgs = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            newArgs[_i] = arguments[_i];
        }
        if (calledOnce && lastThis === this && isEqual(newArgs, lastArgs)) {
            return lastResult;
        }
        lastResult = resultFn.apply(this, newArgs);
        calledOnce = true;
        lastThis = this;
        lastArgs = newArgs;
        return lastResult;
    }
    return memoized;
}

/* harmony default export */ __webpack_exports__["default"] = (memoizeOne);


/***/ }),

/***/ "./node_modules/object-assign/index.js":
/*!*********************************************!*\
  !*** ./node_modules/object-assign/index.js ***!
  \*********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/*
object-assign
(c) Sindre Sorhus
@license MIT
*/


/* eslint-disable no-unused-vars */
var getOwnPropertySymbols = Object.getOwnPropertySymbols;
var hasOwnProperty = Object.prototype.hasOwnProperty;
var propIsEnumerable = Object.prototype.propertyIsEnumerable;

function toObject(val) {
	if (val === null || val === undefined) {
		throw new TypeError('Object.assign cannot be called with null or undefined');
	}

	return Object(val);
}

function shouldUseNative() {
	try {
		if (!Object.assign) {
			return false;
		}

		// Detect buggy property enumeration order in older V8 versions.

		// https://bugs.chromium.org/p/v8/issues/detail?id=4118
		var test1 = new String('abc');  // eslint-disable-line no-new-wrappers
		test1[5] = 'de';
		if (Object.getOwnPropertyNames(test1)[0] === '5') {
			return false;
		}

		// https://bugs.chromium.org/p/v8/issues/detail?id=3056
		var test2 = {};
		for (var i = 0; i < 10; i++) {
			test2['_' + String.fromCharCode(i)] = i;
		}
		var order2 = Object.getOwnPropertyNames(test2).map(function (n) {
			return test2[n];
		});
		if (order2.join('') !== '0123456789') {
			return false;
		}

		// https://bugs.chromium.org/p/v8/issues/detail?id=3056
		var test3 = {};
		'abcdefghijklmnopqrst'.split('').forEach(function (letter) {
			test3[letter] = letter;
		});
		if (Object.keys(Object.assign({}, test3)).join('') !==
				'abcdefghijklmnopqrst') {
			return false;
		}

		return true;
	} catch (err) {
		// We don't expect any of the above to throw, but better to be safe.
		return false;
	}
}

module.exports = shouldUseNative() ? Object.assign : function (target, source) {
	var from;
	var to = toObject(target);
	var symbols;

	for (var s = 1; s < arguments.length; s++) {
		from = Object(arguments[s]);

		for (var key in from) {
			if (hasOwnProperty.call(from, key)) {
				to[key] = from[key];
			}
		}

		if (getOwnPropertySymbols) {
			symbols = getOwnPropertySymbols(from);
			for (var i = 0; i < symbols.length; i++) {
				if (propIsEnumerable.call(from, symbols[i])) {
					to[symbols[i]] = from[symbols[i]];
				}
			}
		}
	}

	return to;
};


/***/ }),

/***/ "./node_modules/prop-types/checkPropTypes.js":
/*!***************************************************!*\
  !*** ./node_modules/prop-types/checkPropTypes.js ***!
  \***************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/**
 * Copyright (c) 2013-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */



var printWarning = function() {};

if (true) {
  var ReactPropTypesSecret = __webpack_require__(/*! ./lib/ReactPropTypesSecret */ "./node_modules/prop-types/lib/ReactPropTypesSecret.js");
  var loggedTypeFailures = {};
  var has = Function.call.bind(Object.prototype.hasOwnProperty);

  printWarning = function(text) {
    var message = 'Warning: ' + text;
    if (typeof console !== 'undefined') {
      console.error(message);
    }
    try {
      // --- Welcome to debugging React ---
      // This error was thrown as a convenience so that you can use this stack
      // to find the callsite that caused this warning to fire.
      throw new Error(message);
    } catch (x) {}
  };
}

/**
 * Assert that the values match with the type specs.
 * Error messages are memorized and will only be shown once.
 *
 * @param {object} typeSpecs Map of name to a ReactPropType
 * @param {object} values Runtime values that need to be type-checked
 * @param {string} location e.g. "prop", "context", "child context"
 * @param {string} componentName Name of the component for error messages.
 * @param {?Function} getStack Returns the component stack.
 * @private
 */
function checkPropTypes(typeSpecs, values, location, componentName, getStack) {
  if (true) {
    for (var typeSpecName in typeSpecs) {
      if (has(typeSpecs, typeSpecName)) {
        var error;
        // Prop type validation may throw. In case they do, we don't want to
        // fail the render phase where it didn't fail before. So we log it.
        // After these have been cleaned up, we'll let them throw.
        try {
          // This is intentionally an invariant that gets caught. It's the same
          // behavior as without this statement except with a better message.
          if (typeof typeSpecs[typeSpecName] !== 'function') {
            var err = Error(
              (componentName || 'React class') + ': ' + location + ' type `' + typeSpecName + '` is invalid; ' +
              'it must be a function, usually from the `prop-types` package, but received `' + typeof typeSpecs[typeSpecName] + '`.'
            );
            err.name = 'Invariant Violation';
            throw err;
          }
          error = typeSpecs[typeSpecName](values, typeSpecName, componentName, location, null, ReactPropTypesSecret);
        } catch (ex) {
          error = ex;
        }
        if (error && !(error instanceof Error)) {
          printWarning(
            (componentName || 'React class') + ': type specification of ' +
            location + ' `' + typeSpecName + '` is invalid; the type checker ' +
            'function must return `null` or an `Error` but returned a ' + typeof error + '. ' +
            'You may have forgotten to pass an argument to the type checker ' +
            'creator (arrayOf, instanceOf, objectOf, oneOf, oneOfType, and ' +
            'shape all require an argument).'
          );
        }
        if (error instanceof Error && !(error.message in loggedTypeFailures)) {
          // Only monitor this failure once because there tends to be a lot of the
          // same error.
          loggedTypeFailures[error.message] = true;

          var stack = getStack ? getStack() : '';

          printWarning(
            'Failed ' + location + ' type: ' + error.message + (stack != null ? stack : '')
          );
        }
      }
    }
  }
}

/**
 * Resets warning cache when testing.
 *
 * @private
 */
checkPropTypes.resetWarningCache = function() {
  if (true) {
    loggedTypeFailures = {};
  }
}

module.exports = checkPropTypes;


/***/ }),

/***/ "./node_modules/prop-types/factoryWithTypeCheckers.js":
/*!************************************************************!*\
  !*** ./node_modules/prop-types/factoryWithTypeCheckers.js ***!
  \************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/**
 * Copyright (c) 2013-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */



var ReactIs = __webpack_require__(/*! react-is */ "./node_modules/react-is/index.js");
var assign = __webpack_require__(/*! object-assign */ "./node_modules/object-assign/index.js");

var ReactPropTypesSecret = __webpack_require__(/*! ./lib/ReactPropTypesSecret */ "./node_modules/prop-types/lib/ReactPropTypesSecret.js");
var checkPropTypes = __webpack_require__(/*! ./checkPropTypes */ "./node_modules/prop-types/checkPropTypes.js");

var has = Function.call.bind(Object.prototype.hasOwnProperty);
var printWarning = function() {};

if (true) {
  printWarning = function(text) {
    var message = 'Warning: ' + text;
    if (typeof console !== 'undefined') {
      console.error(message);
    }
    try {
      // --- Welcome to debugging React ---
      // This error was thrown as a convenience so that you can use this stack
      // to find the callsite that caused this warning to fire.
      throw new Error(message);
    } catch (x) {}
  };
}

function emptyFunctionThatReturnsNull() {
  return null;
}

module.exports = function(isValidElement, throwOnDirectAccess) {
  /* global Symbol */
  var ITERATOR_SYMBOL = typeof Symbol === 'function' && Symbol.iterator;
  var FAUX_ITERATOR_SYMBOL = '@@iterator'; // Before Symbol spec.

  /**
   * Returns the iterator method function contained on the iterable object.
   *
   * Be sure to invoke the function with the iterable as context:
   *
   *     var iteratorFn = getIteratorFn(myIterable);
   *     if (iteratorFn) {
   *       var iterator = iteratorFn.call(myIterable);
   *       ...
   *     }
   *
   * @param {?object} maybeIterable
   * @return {?function}
   */
  function getIteratorFn(maybeIterable) {
    var iteratorFn = maybeIterable && (ITERATOR_SYMBOL && maybeIterable[ITERATOR_SYMBOL] || maybeIterable[FAUX_ITERATOR_SYMBOL]);
    if (typeof iteratorFn === 'function') {
      return iteratorFn;
    }
  }

  /**
   * Collection of methods that allow declaration and validation of props that are
   * supplied to React components. Example usage:
   *
   *   var Props = require('ReactPropTypes');
   *   var MyArticle = React.createClass({
   *     propTypes: {
   *       // An optional string prop named "description".
   *       description: Props.string,
   *
   *       // A required enum prop named "category".
   *       category: Props.oneOf(['News','Photos']).isRequired,
   *
   *       // A prop named "dialog" that requires an instance of Dialog.
   *       dialog: Props.instanceOf(Dialog).isRequired
   *     },
   *     render: function() { ... }
   *   });
   *
   * A more formal specification of how these methods are used:
   *
   *   type := array|bool|func|object|number|string|oneOf([...])|instanceOf(...)
   *   decl := ReactPropTypes.{type}(.isRequired)?
   *
   * Each and every declaration produces a function with the same signature. This
   * allows the creation of custom validation functions. For example:
   *
   *  var MyLink = React.createClass({
   *    propTypes: {
   *      // An optional string or URI prop named "href".
   *      href: function(props, propName, componentName) {
   *        var propValue = props[propName];
   *        if (propValue != null && typeof propValue !== 'string' &&
   *            !(propValue instanceof URI)) {
   *          return new Error(
   *            'Expected a string or an URI for ' + propName + ' in ' +
   *            componentName
   *          );
   *        }
   *      }
   *    },
   *    render: function() {...}
   *  });
   *
   * @internal
   */

  var ANONYMOUS = '<<anonymous>>';

  // Important!
  // Keep this list in sync with production version in `./factoryWithThrowingShims.js`.
  var ReactPropTypes = {
    array: createPrimitiveTypeChecker('array'),
    bool: createPrimitiveTypeChecker('boolean'),
    func: createPrimitiveTypeChecker('function'),
    number: createPrimitiveTypeChecker('number'),
    object: createPrimitiveTypeChecker('object'),
    string: createPrimitiveTypeChecker('string'),
    symbol: createPrimitiveTypeChecker('symbol'),

    any: createAnyTypeChecker(),
    arrayOf: createArrayOfTypeChecker,
    element: createElementTypeChecker(),
    elementType: createElementTypeTypeChecker(),
    instanceOf: createInstanceTypeChecker,
    node: createNodeChecker(),
    objectOf: createObjectOfTypeChecker,
    oneOf: createEnumTypeChecker,
    oneOfType: createUnionTypeChecker,
    shape: createShapeTypeChecker,
    exact: createStrictShapeTypeChecker,
  };

  /**
   * inlined Object.is polyfill to avoid requiring consumers ship their own
   * https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/is
   */
  /*eslint-disable no-self-compare*/
  function is(x, y) {
    // SameValue algorithm
    if (x === y) {
      // Steps 1-5, 7-10
      // Steps 6.b-6.e: +0 != -0
      return x !== 0 || 1 / x === 1 / y;
    } else {
      // Step 6.a: NaN == NaN
      return x !== x && y !== y;
    }
  }
  /*eslint-enable no-self-compare*/

  /**
   * We use an Error-like object for backward compatibility as people may call
   * PropTypes directly and inspect their output. However, we don't use real
   * Errors anymore. We don't inspect their stack anyway, and creating them
   * is prohibitively expensive if they are created too often, such as what
   * happens in oneOfType() for any type before the one that matched.
   */
  function PropTypeError(message) {
    this.message = message;
    this.stack = '';
  }
  // Make `instanceof Error` still work for returned errors.
  PropTypeError.prototype = Error.prototype;

  function createChainableTypeChecker(validate) {
    if (true) {
      var manualPropTypeCallCache = {};
      var manualPropTypeWarningCount = 0;
    }
    function checkType(isRequired, props, propName, componentName, location, propFullName, secret) {
      componentName = componentName || ANONYMOUS;
      propFullName = propFullName || propName;

      if (secret !== ReactPropTypesSecret) {
        if (throwOnDirectAccess) {
          // New behavior only for users of `prop-types` package
          var err = new Error(
            'Calling PropTypes validators directly is not supported by the `prop-types` package. ' +
            'Use `PropTypes.checkPropTypes()` to call them. ' +
            'Read more at http://fb.me/use-check-prop-types'
          );
          err.name = 'Invariant Violation';
          throw err;
        } else if ( true && typeof console !== 'undefined') {
          // Old behavior for people using React.PropTypes
          var cacheKey = componentName + ':' + propName;
          if (
            !manualPropTypeCallCache[cacheKey] &&
            // Avoid spamming the console because they are often not actionable except for lib authors
            manualPropTypeWarningCount < 3
          ) {
            printWarning(
              'You are manually calling a React.PropTypes validation ' +
              'function for the `' + propFullName + '` prop on `' + componentName  + '`. This is deprecated ' +
              'and will throw in the standalone `prop-types` package. ' +
              'You may be seeing this warning due to a third-party PropTypes ' +
              'library. See https://fb.me/react-warning-dont-call-proptypes ' + 'for details.'
            );
            manualPropTypeCallCache[cacheKey] = true;
            manualPropTypeWarningCount++;
          }
        }
      }
      if (props[propName] == null) {
        if (isRequired) {
          if (props[propName] === null) {
            return new PropTypeError('The ' + location + ' `' + propFullName + '` is marked as required ' + ('in `' + componentName + '`, but its value is `null`.'));
          }
          return new PropTypeError('The ' + location + ' `' + propFullName + '` is marked as required in ' + ('`' + componentName + '`, but its value is `undefined`.'));
        }
        return null;
      } else {
        return validate(props, propName, componentName, location, propFullName);
      }
    }

    var chainedCheckType = checkType.bind(null, false);
    chainedCheckType.isRequired = checkType.bind(null, true);

    return chainedCheckType;
  }

  function createPrimitiveTypeChecker(expectedType) {
    function validate(props, propName, componentName, location, propFullName, secret) {
      var propValue = props[propName];
      var propType = getPropType(propValue);
      if (propType !== expectedType) {
        // `propValue` being instance of, say, date/regexp, pass the 'object'
        // check, but we can offer a more precise error message here rather than
        // 'of type `object`'.
        var preciseType = getPreciseType(propValue);

        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type ' + ('`' + preciseType + '` supplied to `' + componentName + '`, expected ') + ('`' + expectedType + '`.'));
      }
      return null;
    }
    return createChainableTypeChecker(validate);
  }

  function createAnyTypeChecker() {
    return createChainableTypeChecker(emptyFunctionThatReturnsNull);
  }

  function createArrayOfTypeChecker(typeChecker) {
    function validate(props, propName, componentName, location, propFullName) {
      if (typeof typeChecker !== 'function') {
        return new PropTypeError('Property `' + propFullName + '` of component `' + componentName + '` has invalid PropType notation inside arrayOf.');
      }
      var propValue = props[propName];
      if (!Array.isArray(propValue)) {
        var propType = getPropType(propValue);
        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type ' + ('`' + propType + '` supplied to `' + componentName + '`, expected an array.'));
      }
      for (var i = 0; i < propValue.length; i++) {
        var error = typeChecker(propValue, i, componentName, location, propFullName + '[' + i + ']', ReactPropTypesSecret);
        if (error instanceof Error) {
          return error;
        }
      }
      return null;
    }
    return createChainableTypeChecker(validate);
  }

  function createElementTypeChecker() {
    function validate(props, propName, componentName, location, propFullName) {
      var propValue = props[propName];
      if (!isValidElement(propValue)) {
        var propType = getPropType(propValue);
        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type ' + ('`' + propType + '` supplied to `' + componentName + '`, expected a single ReactElement.'));
      }
      return null;
    }
    return createChainableTypeChecker(validate);
  }

  function createElementTypeTypeChecker() {
    function validate(props, propName, componentName, location, propFullName) {
      var propValue = props[propName];
      if (!ReactIs.isValidElementType(propValue)) {
        var propType = getPropType(propValue);
        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type ' + ('`' + propType + '` supplied to `' + componentName + '`, expected a single ReactElement type.'));
      }
      return null;
    }
    return createChainableTypeChecker(validate);
  }

  function createInstanceTypeChecker(expectedClass) {
    function validate(props, propName, componentName, location, propFullName) {
      if (!(props[propName] instanceof expectedClass)) {
        var expectedClassName = expectedClass.name || ANONYMOUS;
        var actualClassName = getClassName(props[propName]);
        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type ' + ('`' + actualClassName + '` supplied to `' + componentName + '`, expected ') + ('instance of `' + expectedClassName + '`.'));
      }
      return null;
    }
    return createChainableTypeChecker(validate);
  }

  function createEnumTypeChecker(expectedValues) {
    if (!Array.isArray(expectedValues)) {
      if (true) {
        if (arguments.length > 1) {
          printWarning(
            'Invalid arguments supplied to oneOf, expected an array, got ' + arguments.length + ' arguments. ' +
            'A common mistake is to write oneOf(x, y, z) instead of oneOf([x, y, z]).'
          );
        } else {
          printWarning('Invalid argument supplied to oneOf, expected an array.');
        }
      }
      return emptyFunctionThatReturnsNull;
    }

    function validate(props, propName, componentName, location, propFullName) {
      var propValue = props[propName];
      for (var i = 0; i < expectedValues.length; i++) {
        if (is(propValue, expectedValues[i])) {
          return null;
        }
      }

      var valuesString = JSON.stringify(expectedValues, function replacer(key, value) {
        var type = getPreciseType(value);
        if (type === 'symbol') {
          return String(value);
        }
        return value;
      });
      return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of value `' + String(propValue) + '` ' + ('supplied to `' + componentName + '`, expected one of ' + valuesString + '.'));
    }
    return createChainableTypeChecker(validate);
  }

  function createObjectOfTypeChecker(typeChecker) {
    function validate(props, propName, componentName, location, propFullName) {
      if (typeof typeChecker !== 'function') {
        return new PropTypeError('Property `' + propFullName + '` of component `' + componentName + '` has invalid PropType notation inside objectOf.');
      }
      var propValue = props[propName];
      var propType = getPropType(propValue);
      if (propType !== 'object') {
        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type ' + ('`' + propType + '` supplied to `' + componentName + '`, expected an object.'));
      }
      for (var key in propValue) {
        if (has(propValue, key)) {
          var error = typeChecker(propValue, key, componentName, location, propFullName + '.' + key, ReactPropTypesSecret);
          if (error instanceof Error) {
            return error;
          }
        }
      }
      return null;
    }
    return createChainableTypeChecker(validate);
  }

  function createUnionTypeChecker(arrayOfTypeCheckers) {
    if (!Array.isArray(arrayOfTypeCheckers)) {
       true ? printWarning('Invalid argument supplied to oneOfType, expected an instance of array.') : undefined;
      return emptyFunctionThatReturnsNull;
    }

    for (var i = 0; i < arrayOfTypeCheckers.length; i++) {
      var checker = arrayOfTypeCheckers[i];
      if (typeof checker !== 'function') {
        printWarning(
          'Invalid argument supplied to oneOfType. Expected an array of check functions, but ' +
          'received ' + getPostfixForTypeWarning(checker) + ' at index ' + i + '.'
        );
        return emptyFunctionThatReturnsNull;
      }
    }

    function validate(props, propName, componentName, location, propFullName) {
      for (var i = 0; i < arrayOfTypeCheckers.length; i++) {
        var checker = arrayOfTypeCheckers[i];
        if (checker(props, propName, componentName, location, propFullName, ReactPropTypesSecret) == null) {
          return null;
        }
      }

      return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` supplied to ' + ('`' + componentName + '`.'));
    }
    return createChainableTypeChecker(validate);
  }

  function createNodeChecker() {
    function validate(props, propName, componentName, location, propFullName) {
      if (!isNode(props[propName])) {
        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` supplied to ' + ('`' + componentName + '`, expected a ReactNode.'));
      }
      return null;
    }
    return createChainableTypeChecker(validate);
  }

  function createShapeTypeChecker(shapeTypes) {
    function validate(props, propName, componentName, location, propFullName) {
      var propValue = props[propName];
      var propType = getPropType(propValue);
      if (propType !== 'object') {
        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type `' + propType + '` ' + ('supplied to `' + componentName + '`, expected `object`.'));
      }
      for (var key in shapeTypes) {
        var checker = shapeTypes[key];
        if (!checker) {
          continue;
        }
        var error = checker(propValue, key, componentName, location, propFullName + '.' + key, ReactPropTypesSecret);
        if (error) {
          return error;
        }
      }
      return null;
    }
    return createChainableTypeChecker(validate);
  }

  function createStrictShapeTypeChecker(shapeTypes) {
    function validate(props, propName, componentName, location, propFullName) {
      var propValue = props[propName];
      var propType = getPropType(propValue);
      if (propType !== 'object') {
        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type `' + propType + '` ' + ('supplied to `' + componentName + '`, expected `object`.'));
      }
      // We need to check all keys in case some are required but missing from
      // props.
      var allKeys = assign({}, props[propName], shapeTypes);
      for (var key in allKeys) {
        var checker = shapeTypes[key];
        if (!checker) {
          return new PropTypeError(
            'Invalid ' + location + ' `' + propFullName + '` key `' + key + '` supplied to `' + componentName + '`.' +
            '\nBad object: ' + JSON.stringify(props[propName], null, '  ') +
            '\nValid keys: ' +  JSON.stringify(Object.keys(shapeTypes), null, '  ')
          );
        }
        var error = checker(propValue, key, componentName, location, propFullName + '.' + key, ReactPropTypesSecret);
        if (error) {
          return error;
        }
      }
      return null;
    }

    return createChainableTypeChecker(validate);
  }

  function isNode(propValue) {
    switch (typeof propValue) {
      case 'number':
      case 'string':
      case 'undefined':
        return true;
      case 'boolean':
        return !propValue;
      case 'object':
        if (Array.isArray(propValue)) {
          return propValue.every(isNode);
        }
        if (propValue === null || isValidElement(propValue)) {
          return true;
        }

        var iteratorFn = getIteratorFn(propValue);
        if (iteratorFn) {
          var iterator = iteratorFn.call(propValue);
          var step;
          if (iteratorFn !== propValue.entries) {
            while (!(step = iterator.next()).done) {
              if (!isNode(step.value)) {
                return false;
              }
            }
          } else {
            // Iterator will provide entry [k,v] tuples rather than values.
            while (!(step = iterator.next()).done) {
              var entry = step.value;
              if (entry) {
                if (!isNode(entry[1])) {
                  return false;
                }
              }
            }
          }
        } else {
          return false;
        }

        return true;
      default:
        return false;
    }
  }

  function isSymbol(propType, propValue) {
    // Native Symbol.
    if (propType === 'symbol') {
      return true;
    }

    // falsy value can't be a Symbol
    if (!propValue) {
      return false;
    }

    // 19.4.3.5 Symbol.prototype[@@toStringTag] === 'Symbol'
    if (propValue['@@toStringTag'] === 'Symbol') {
      return true;
    }

    // Fallback for non-spec compliant Symbols which are polyfilled.
    if (typeof Symbol === 'function' && propValue instanceof Symbol) {
      return true;
    }

    return false;
  }

  // Equivalent of `typeof` but with special handling for array and regexp.
  function getPropType(propValue) {
    var propType = typeof propValue;
    if (Array.isArray(propValue)) {
      return 'array';
    }
    if (propValue instanceof RegExp) {
      // Old webkits (at least until Android 4.0) return 'function' rather than
      // 'object' for typeof a RegExp. We'll normalize this here so that /bla/
      // passes PropTypes.object.
      return 'object';
    }
    if (isSymbol(propType, propValue)) {
      return 'symbol';
    }
    return propType;
  }

  // This handles more types than `getPropType`. Only used for error messages.
  // See `createPrimitiveTypeChecker`.
  function getPreciseType(propValue) {
    if (typeof propValue === 'undefined' || propValue === null) {
      return '' + propValue;
    }
    var propType = getPropType(propValue);
    if (propType === 'object') {
      if (propValue instanceof Date) {
        return 'date';
      } else if (propValue instanceof RegExp) {
        return 'regexp';
      }
    }
    return propType;
  }

  // Returns a string that is postfixed to a warning about an invalid type.
  // For example, "undefined" or "of type array"
  function getPostfixForTypeWarning(value) {
    var type = getPreciseType(value);
    switch (type) {
      case 'array':
      case 'object':
        return 'an ' + type;
      case 'boolean':
      case 'date':
      case 'regexp':
        return 'a ' + type;
      default:
        return type;
    }
  }

  // Returns class name of the object, if any.
  function getClassName(propValue) {
    if (!propValue.constructor || !propValue.constructor.name) {
      return ANONYMOUS;
    }
    return propValue.constructor.name;
  }

  ReactPropTypes.checkPropTypes = checkPropTypes;
  ReactPropTypes.resetWarningCache = checkPropTypes.resetWarningCache;
  ReactPropTypes.PropTypes = ReactPropTypes;

  return ReactPropTypes;
};


/***/ }),

/***/ "./node_modules/prop-types/index.js":
/*!******************************************!*\
  !*** ./node_modules/prop-types/index.js ***!
  \******************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

/**
 * Copyright (c) 2013-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

if (true) {
  var ReactIs = __webpack_require__(/*! react-is */ "./node_modules/react-is/index.js");

  // By explicitly using `prop-types` you are opting into new development behavior.
  // http://fb.me/prop-types-in-prod
  var throwOnDirectAccess = true;
  module.exports = __webpack_require__(/*! ./factoryWithTypeCheckers */ "./node_modules/prop-types/factoryWithTypeCheckers.js")(ReactIs.isElement, throwOnDirectAccess);
} else {}


/***/ }),

/***/ "./node_modules/prop-types/lib/ReactPropTypesSecret.js":
/*!*************************************************************!*\
  !*** ./node_modules/prop-types/lib/ReactPropTypesSecret.js ***!
  \*************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/**
 * Copyright (c) 2013-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */



var ReactPropTypesSecret = 'SECRET_DO_NOT_PASS_THIS_OR_YOU_WILL_BE_FIRED';

module.exports = ReactPropTypesSecret;


/***/ }),

/***/ "./node_modules/react-input-autosize/lib/AutosizeInput.js":
/*!****************************************************************!*\
  !*** ./node_modules/react-input-autosize/lib/AutosizeInput.js ***!
  \****************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
	value: true
});

var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _react = __webpack_require__(/*! react */ "react");

var _react2 = _interopRequireDefault(_react);

var _propTypes = __webpack_require__(/*! prop-types */ "./node_modules/prop-types/index.js");

var _propTypes2 = _interopRequireDefault(_propTypes);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _objectWithoutProperties(obj, keys) { var target = {}; for (var i in obj) { if (keys.indexOf(i) >= 0) continue; if (!Object.prototype.hasOwnProperty.call(obj, i)) continue; target[i] = obj[i]; } return target; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var sizerStyle = {
	position: 'absolute',
	top: 0,
	left: 0,
	visibility: 'hidden',
	height: 0,
	overflow: 'scroll',
	whiteSpace: 'pre'
};

var INPUT_PROPS_BLACKLIST = ['extraWidth', 'injectStyles', 'inputClassName', 'inputRef', 'inputStyle', 'minWidth', 'onAutosize', 'placeholderIsMinWidth'];

var cleanInputProps = function cleanInputProps(inputProps) {
	INPUT_PROPS_BLACKLIST.forEach(function (field) {
		return delete inputProps[field];
	});
	return inputProps;
};

var copyStyles = function copyStyles(styles, node) {
	node.style.fontSize = styles.fontSize;
	node.style.fontFamily = styles.fontFamily;
	node.style.fontWeight = styles.fontWeight;
	node.style.fontStyle = styles.fontStyle;
	node.style.letterSpacing = styles.letterSpacing;
	node.style.textTransform = styles.textTransform;
};

var isIE = typeof window !== 'undefined' && window.navigator ? /MSIE |Trident\/|Edge\//.test(window.navigator.userAgent) : false;

var generateId = function generateId() {
	// we only need an auto-generated ID for stylesheet injection, which is only
	// used for IE. so if the browser is not IE, this should return undefined.
	return isIE ? '_' + Math.random().toString(36).substr(2, 12) : undefined;
};

var AutosizeInput = function (_Component) {
	_inherits(AutosizeInput, _Component);

	function AutosizeInput(props) {
		_classCallCheck(this, AutosizeInput);

		var _this = _possibleConstructorReturn(this, (AutosizeInput.__proto__ || Object.getPrototypeOf(AutosizeInput)).call(this, props));

		_this.inputRef = function (el) {
			_this.input = el;
			if (typeof _this.props.inputRef === 'function') {
				_this.props.inputRef(el);
			}
		};

		_this.placeHolderSizerRef = function (el) {
			_this.placeHolderSizer = el;
		};

		_this.sizerRef = function (el) {
			_this.sizer = el;
		};

		_this.state = {
			inputWidth: props.minWidth,
			inputId: props.id || generateId()
		};
		return _this;
	}

	_createClass(AutosizeInput, [{
		key: 'componentDidMount',
		value: function componentDidMount() {
			this.mounted = true;
			this.copyInputStyles();
			this.updateInputWidth();
		}
	}, {
		key: 'UNSAFE_componentWillReceiveProps',
		value: function UNSAFE_componentWillReceiveProps(nextProps) {
			var id = nextProps.id;

			if (id !== this.props.id) {
				this.setState({ inputId: id || generateId() });
			}
		}
	}, {
		key: 'componentDidUpdate',
		value: function componentDidUpdate(prevProps, prevState) {
			if (prevState.inputWidth !== this.state.inputWidth) {
				if (typeof this.props.onAutosize === 'function') {
					this.props.onAutosize(this.state.inputWidth);
				}
			}
			this.updateInputWidth();
		}
	}, {
		key: 'componentWillUnmount',
		value: function componentWillUnmount() {
			this.mounted = false;
		}
	}, {
		key: 'copyInputStyles',
		value: function copyInputStyles() {
			if (!this.mounted || !window.getComputedStyle) {
				return;
			}
			var inputStyles = this.input && window.getComputedStyle(this.input);
			if (!inputStyles) {
				return;
			}
			copyStyles(inputStyles, this.sizer);
			if (this.placeHolderSizer) {
				copyStyles(inputStyles, this.placeHolderSizer);
			}
		}
	}, {
		key: 'updateInputWidth',
		value: function updateInputWidth() {
			if (!this.mounted || !this.sizer || typeof this.sizer.scrollWidth === 'undefined') {
				return;
			}
			var newInputWidth = void 0;
			if (this.props.placeholder && (!this.props.value || this.props.value && this.props.placeholderIsMinWidth)) {
				newInputWidth = Math.max(this.sizer.scrollWidth, this.placeHolderSizer.scrollWidth) + 2;
			} else {
				newInputWidth = this.sizer.scrollWidth + 2;
			}
			// add extraWidth to the detected width. for number types, this defaults to 16 to allow for the stepper UI
			var extraWidth = this.props.type === 'number' && this.props.extraWidth === undefined ? 16 : parseInt(this.props.extraWidth) || 0;
			newInputWidth += extraWidth;
			if (newInputWidth < this.props.minWidth) {
				newInputWidth = this.props.minWidth;
			}
			if (newInputWidth !== this.state.inputWidth) {
				this.setState({
					inputWidth: newInputWidth
				});
			}
		}
	}, {
		key: 'getInput',
		value: function getInput() {
			return this.input;
		}
	}, {
		key: 'focus',
		value: function focus() {
			this.input.focus();
		}
	}, {
		key: 'blur',
		value: function blur() {
			this.input.blur();
		}
	}, {
		key: 'select',
		value: function select() {
			this.input.select();
		}
	}, {
		key: 'renderStyles',
		value: function renderStyles() {
			// this method injects styles to hide IE's clear indicator, which messes
			// with input size detection. the stylesheet is only injected when the
			// browser is IE, and can also be disabled by the `injectStyles` prop.
			var injectStyles = this.props.injectStyles;

			return isIE && injectStyles ? _react2.default.createElement('style', { dangerouslySetInnerHTML: {
					__html: 'input#' + this.state.inputId + '::-ms-clear {display: none;}'
				} }) : null;
		}
	}, {
		key: 'render',
		value: function render() {
			var sizerValue = [this.props.defaultValue, this.props.value, ''].reduce(function (previousValue, currentValue) {
				if (previousValue !== null && previousValue !== undefined) {
					return previousValue;
				}
				return currentValue;
			});

			var wrapperStyle = _extends({}, this.props.style);
			if (!wrapperStyle.display) wrapperStyle.display = 'inline-block';

			var inputStyle = _extends({
				boxSizing: 'content-box',
				width: this.state.inputWidth + 'px'
			}, this.props.inputStyle);

			var inputProps = _objectWithoutProperties(this.props, []);

			cleanInputProps(inputProps);
			inputProps.className = this.props.inputClassName;
			inputProps.id = this.state.inputId;
			inputProps.style = inputStyle;

			return _react2.default.createElement(
				'div',
				{ className: this.props.className, style: wrapperStyle },
				this.renderStyles(),
				_react2.default.createElement('input', _extends({}, inputProps, { ref: this.inputRef })),
				_react2.default.createElement(
					'div',
					{ ref: this.sizerRef, style: sizerStyle },
					sizerValue
				),
				this.props.placeholder ? _react2.default.createElement(
					'div',
					{ ref: this.placeHolderSizerRef, style: sizerStyle },
					this.props.placeholder
				) : null
			);
		}
	}]);

	return AutosizeInput;
}(_react.Component);

AutosizeInput.propTypes = {
	className: _propTypes2.default.string, // className for the outer element
	defaultValue: _propTypes2.default.any, // default field value
	extraWidth: _propTypes2.default.oneOfType([// additional width for input element
	_propTypes2.default.number, _propTypes2.default.string]),
	id: _propTypes2.default.string, // id to use for the input, can be set for consistent snapshots
	injectStyles: _propTypes2.default.bool, // inject the custom stylesheet to hide clear UI, defaults to true
	inputClassName: _propTypes2.default.string, // className for the input element
	inputRef: _propTypes2.default.func, // ref callback for the input element
	inputStyle: _propTypes2.default.object, // css styles for the input element
	minWidth: _propTypes2.default.oneOfType([// minimum width for input element
	_propTypes2.default.number, _propTypes2.default.string]),
	onAutosize: _propTypes2.default.func, // onAutosize handler: function(newWidth) {}
	onChange: _propTypes2.default.func, // onChange handler: function(event) {}
	placeholder: _propTypes2.default.string, // placeholder text
	placeholderIsMinWidth: _propTypes2.default.bool, // don't collapse size to less than the placeholder
	style: _propTypes2.default.object, // css styles for the outer element
	value: _propTypes2.default.any // field value
};
AutosizeInput.defaultProps = {
	minWidth: 1,
	injectStyles: true
};

exports.default = AutosizeInput;

/***/ }),

/***/ "./node_modules/react-is/cjs/react-is.development.js":
/*!***********************************************************!*\
  !*** ./node_modules/react-is/cjs/react-is.development.js ***!
  \***********************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/** @license React v16.8.6
 * react-is.development.js
 *
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */





if (true) {
  (function() {
'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

// The Symbol used to tag the ReactElement-like types. If there is no native Symbol
// nor polyfill, then a plain number is used for performance.
var hasSymbol = typeof Symbol === 'function' && Symbol.for;

var REACT_ELEMENT_TYPE = hasSymbol ? Symbol.for('react.element') : 0xeac7;
var REACT_PORTAL_TYPE = hasSymbol ? Symbol.for('react.portal') : 0xeaca;
var REACT_FRAGMENT_TYPE = hasSymbol ? Symbol.for('react.fragment') : 0xeacb;
var REACT_STRICT_MODE_TYPE = hasSymbol ? Symbol.for('react.strict_mode') : 0xeacc;
var REACT_PROFILER_TYPE = hasSymbol ? Symbol.for('react.profiler') : 0xead2;
var REACT_PROVIDER_TYPE = hasSymbol ? Symbol.for('react.provider') : 0xeacd;
var REACT_CONTEXT_TYPE = hasSymbol ? Symbol.for('react.context') : 0xeace;
var REACT_ASYNC_MODE_TYPE = hasSymbol ? Symbol.for('react.async_mode') : 0xeacf;
var REACT_CONCURRENT_MODE_TYPE = hasSymbol ? Symbol.for('react.concurrent_mode') : 0xeacf;
var REACT_FORWARD_REF_TYPE = hasSymbol ? Symbol.for('react.forward_ref') : 0xead0;
var REACT_SUSPENSE_TYPE = hasSymbol ? Symbol.for('react.suspense') : 0xead1;
var REACT_MEMO_TYPE = hasSymbol ? Symbol.for('react.memo') : 0xead3;
var REACT_LAZY_TYPE = hasSymbol ? Symbol.for('react.lazy') : 0xead4;

function isValidElementType(type) {
  return typeof type === 'string' || typeof type === 'function' ||
  // Note: its typeof might be other than 'symbol' or 'number' if it's a polyfill.
  type === REACT_FRAGMENT_TYPE || type === REACT_CONCURRENT_MODE_TYPE || type === REACT_PROFILER_TYPE || type === REACT_STRICT_MODE_TYPE || type === REACT_SUSPENSE_TYPE || typeof type === 'object' && type !== null && (type.$$typeof === REACT_LAZY_TYPE || type.$$typeof === REACT_MEMO_TYPE || type.$$typeof === REACT_PROVIDER_TYPE || type.$$typeof === REACT_CONTEXT_TYPE || type.$$typeof === REACT_FORWARD_REF_TYPE);
}

/**
 * Forked from fbjs/warning:
 * https://github.com/facebook/fbjs/blob/e66ba20ad5be433eb54423f2b097d829324d9de6/packages/fbjs/src/__forks__/warning.js
 *
 * Only change is we use console.warn instead of console.error,
 * and do nothing when 'console' is not supported.
 * This really simplifies the code.
 * ---
 * Similar to invariant but only logs a warning if the condition is not met.
 * This can be used to log issues in development environments in critical
 * paths. Removing the logging code for production environments will keep the
 * same logic and follow the same code paths.
 */

var lowPriorityWarning = function () {};

{
  var printWarning = function (format) {
    for (var _len = arguments.length, args = Array(_len > 1 ? _len - 1 : 0), _key = 1; _key < _len; _key++) {
      args[_key - 1] = arguments[_key];
    }

    var argIndex = 0;
    var message = 'Warning: ' + format.replace(/%s/g, function () {
      return args[argIndex++];
    });
    if (typeof console !== 'undefined') {
      console.warn(message);
    }
    try {
      // --- Welcome to debugging React ---
      // This error was thrown as a convenience so that you can use this stack
      // to find the callsite that caused this warning to fire.
      throw new Error(message);
    } catch (x) {}
  };

  lowPriorityWarning = function (condition, format) {
    if (format === undefined) {
      throw new Error('`lowPriorityWarning(condition, format, ...args)` requires a warning ' + 'message argument');
    }
    if (!condition) {
      for (var _len2 = arguments.length, args = Array(_len2 > 2 ? _len2 - 2 : 0), _key2 = 2; _key2 < _len2; _key2++) {
        args[_key2 - 2] = arguments[_key2];
      }

      printWarning.apply(undefined, [format].concat(args));
    }
  };
}

var lowPriorityWarning$1 = lowPriorityWarning;

function typeOf(object) {
  if (typeof object === 'object' && object !== null) {
    var $$typeof = object.$$typeof;
    switch ($$typeof) {
      case REACT_ELEMENT_TYPE:
        var type = object.type;

        switch (type) {
          case REACT_ASYNC_MODE_TYPE:
          case REACT_CONCURRENT_MODE_TYPE:
          case REACT_FRAGMENT_TYPE:
          case REACT_PROFILER_TYPE:
          case REACT_STRICT_MODE_TYPE:
          case REACT_SUSPENSE_TYPE:
            return type;
          default:
            var $$typeofType = type && type.$$typeof;

            switch ($$typeofType) {
              case REACT_CONTEXT_TYPE:
              case REACT_FORWARD_REF_TYPE:
              case REACT_PROVIDER_TYPE:
                return $$typeofType;
              default:
                return $$typeof;
            }
        }
      case REACT_LAZY_TYPE:
      case REACT_MEMO_TYPE:
      case REACT_PORTAL_TYPE:
        return $$typeof;
    }
  }

  return undefined;
}

// AsyncMode is deprecated along with isAsyncMode
var AsyncMode = REACT_ASYNC_MODE_TYPE;
var ConcurrentMode = REACT_CONCURRENT_MODE_TYPE;
var ContextConsumer = REACT_CONTEXT_TYPE;
var ContextProvider = REACT_PROVIDER_TYPE;
var Element = REACT_ELEMENT_TYPE;
var ForwardRef = REACT_FORWARD_REF_TYPE;
var Fragment = REACT_FRAGMENT_TYPE;
var Lazy = REACT_LAZY_TYPE;
var Memo = REACT_MEMO_TYPE;
var Portal = REACT_PORTAL_TYPE;
var Profiler = REACT_PROFILER_TYPE;
var StrictMode = REACT_STRICT_MODE_TYPE;
var Suspense = REACT_SUSPENSE_TYPE;

var hasWarnedAboutDeprecatedIsAsyncMode = false;

// AsyncMode should be deprecated
function isAsyncMode(object) {
  {
    if (!hasWarnedAboutDeprecatedIsAsyncMode) {
      hasWarnedAboutDeprecatedIsAsyncMode = true;
      lowPriorityWarning$1(false, 'The ReactIs.isAsyncMode() alias has been deprecated, ' + 'and will be removed in React 17+. Update your code to use ' + 'ReactIs.isConcurrentMode() instead. It has the exact same API.');
    }
  }
  return isConcurrentMode(object) || typeOf(object) === REACT_ASYNC_MODE_TYPE;
}
function isConcurrentMode(object) {
  return typeOf(object) === REACT_CONCURRENT_MODE_TYPE;
}
function isContextConsumer(object) {
  return typeOf(object) === REACT_CONTEXT_TYPE;
}
function isContextProvider(object) {
  return typeOf(object) === REACT_PROVIDER_TYPE;
}
function isElement(object) {
  return typeof object === 'object' && object !== null && object.$$typeof === REACT_ELEMENT_TYPE;
}
function isForwardRef(object) {
  return typeOf(object) === REACT_FORWARD_REF_TYPE;
}
function isFragment(object) {
  return typeOf(object) === REACT_FRAGMENT_TYPE;
}
function isLazy(object) {
  return typeOf(object) === REACT_LAZY_TYPE;
}
function isMemo(object) {
  return typeOf(object) === REACT_MEMO_TYPE;
}
function isPortal(object) {
  return typeOf(object) === REACT_PORTAL_TYPE;
}
function isProfiler(object) {
  return typeOf(object) === REACT_PROFILER_TYPE;
}
function isStrictMode(object) {
  return typeOf(object) === REACT_STRICT_MODE_TYPE;
}
function isSuspense(object) {
  return typeOf(object) === REACT_SUSPENSE_TYPE;
}

exports.typeOf = typeOf;
exports.AsyncMode = AsyncMode;
exports.ConcurrentMode = ConcurrentMode;
exports.ContextConsumer = ContextConsumer;
exports.ContextProvider = ContextProvider;
exports.Element = Element;
exports.ForwardRef = ForwardRef;
exports.Fragment = Fragment;
exports.Lazy = Lazy;
exports.Memo = Memo;
exports.Portal = Portal;
exports.Profiler = Profiler;
exports.StrictMode = StrictMode;
exports.Suspense = Suspense;
exports.isValidElementType = isValidElementType;
exports.isAsyncMode = isAsyncMode;
exports.isConcurrentMode = isConcurrentMode;
exports.isContextConsumer = isContextConsumer;
exports.isContextProvider = isContextProvider;
exports.isElement = isElement;
exports.isForwardRef = isForwardRef;
exports.isFragment = isFragment;
exports.isLazy = isLazy;
exports.isMemo = isMemo;
exports.isPortal = isPortal;
exports.isProfiler = isProfiler;
exports.isStrictMode = isStrictMode;
exports.isSuspense = isSuspense;
  })();
}


/***/ }),

/***/ "./node_modules/react-is/index.js":
/*!****************************************!*\
  !*** ./node_modules/react-is/index.js ***!
  \****************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


if (false) {} else {
  module.exports = __webpack_require__(/*! ./cjs/react-is.development.js */ "./node_modules/react-is/cjs/react-is.development.js");
}


/***/ }),

/***/ "./node_modules/react-select/dist/Select-9fdb8cd0.browser.esm.js":
/*!***********************************************************************!*\
  !*** ./node_modules/react-select/dist/Select-9fdb8cd0.browser.esm.js ***!
  \***********************************************************************/
/*! exports provided: S, a, c, d, m */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "S", function() { return Select; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return defaultTheme; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "c", function() { return createFilter; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "d", function() { return defaultProps; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "m", function() { return mergeStyles; });
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var memoize_one__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! memoize-one */ "./node_modules/memoize-one/dist/memoize-one.esm.js");
/* harmony import */ var _emotion_core__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @emotion/core */ "./node_modules/@emotion/core/dist/core.browser.esm.js");
/* harmony import */ var react_dom__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! react-dom */ "react-dom");
/* harmony import */ var react_dom__WEBPACK_IMPORTED_MODULE_3___default = /*#__PURE__*/__webpack_require__.n(react_dom__WEBPACK_IMPORTED_MODULE_3__);
/* harmony import */ var _utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./utils-06b0d5a4.browser.esm.js */ "./node_modules/react-select/dist/utils-06b0d5a4.browser.esm.js");
/* harmony import */ var _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ./index-4322c0ed.browser.esm.js */ "./node_modules/react-select/dist/index-4322c0ed.browser.esm.js");
/* harmony import */ var _emotion_css__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! @emotion/css */ "./node_modules/@emotion/css/dist/css.browser.esm.js");








var diacritics = [{
  base: 'A',
  letters: /[\u0041\u24B6\uFF21\u00C0\u00C1\u00C2\u1EA6\u1EA4\u1EAA\u1EA8\u00C3\u0100\u0102\u1EB0\u1EAE\u1EB4\u1EB2\u0226\u01E0\u00C4\u01DE\u1EA2\u00C5\u01FA\u01CD\u0200\u0202\u1EA0\u1EAC\u1EB6\u1E00\u0104\u023A\u2C6F]/g
}, {
  base: 'AA',
  letters: /[\uA732]/g
}, {
  base: 'AE',
  letters: /[\u00C6\u01FC\u01E2]/g
}, {
  base: 'AO',
  letters: /[\uA734]/g
}, {
  base: 'AU',
  letters: /[\uA736]/g
}, {
  base: 'AV',
  letters: /[\uA738\uA73A]/g
}, {
  base: 'AY',
  letters: /[\uA73C]/g
}, {
  base: 'B',
  letters: /[\u0042\u24B7\uFF22\u1E02\u1E04\u1E06\u0243\u0182\u0181]/g
}, {
  base: 'C',
  letters: /[\u0043\u24B8\uFF23\u0106\u0108\u010A\u010C\u00C7\u1E08\u0187\u023B\uA73E]/g
}, {
  base: 'D',
  letters: /[\u0044\u24B9\uFF24\u1E0A\u010E\u1E0C\u1E10\u1E12\u1E0E\u0110\u018B\u018A\u0189\uA779]/g
}, {
  base: 'DZ',
  letters: /[\u01F1\u01C4]/g
}, {
  base: 'Dz',
  letters: /[\u01F2\u01C5]/g
}, {
  base: 'E',
  letters: /[\u0045\u24BA\uFF25\u00C8\u00C9\u00CA\u1EC0\u1EBE\u1EC4\u1EC2\u1EBC\u0112\u1E14\u1E16\u0114\u0116\u00CB\u1EBA\u011A\u0204\u0206\u1EB8\u1EC6\u0228\u1E1C\u0118\u1E18\u1E1A\u0190\u018E]/g
}, {
  base: 'F',
  letters: /[\u0046\u24BB\uFF26\u1E1E\u0191\uA77B]/g
}, {
  base: 'G',
  letters: /[\u0047\u24BC\uFF27\u01F4\u011C\u1E20\u011E\u0120\u01E6\u0122\u01E4\u0193\uA7A0\uA77D\uA77E]/g
}, {
  base: 'H',
  letters: /[\u0048\u24BD\uFF28\u0124\u1E22\u1E26\u021E\u1E24\u1E28\u1E2A\u0126\u2C67\u2C75\uA78D]/g
}, {
  base: 'I',
  letters: /[\u0049\u24BE\uFF29\u00CC\u00CD\u00CE\u0128\u012A\u012C\u0130\u00CF\u1E2E\u1EC8\u01CF\u0208\u020A\u1ECA\u012E\u1E2C\u0197]/g
}, {
  base: 'J',
  letters: /[\u004A\u24BF\uFF2A\u0134\u0248]/g
}, {
  base: 'K',
  letters: /[\u004B\u24C0\uFF2B\u1E30\u01E8\u1E32\u0136\u1E34\u0198\u2C69\uA740\uA742\uA744\uA7A2]/g
}, {
  base: 'L',
  letters: /[\u004C\u24C1\uFF2C\u013F\u0139\u013D\u1E36\u1E38\u013B\u1E3C\u1E3A\u0141\u023D\u2C62\u2C60\uA748\uA746\uA780]/g
}, {
  base: 'LJ',
  letters: /[\u01C7]/g
}, {
  base: 'Lj',
  letters: /[\u01C8]/g
}, {
  base: 'M',
  letters: /[\u004D\u24C2\uFF2D\u1E3E\u1E40\u1E42\u2C6E\u019C]/g
}, {
  base: 'N',
  letters: /[\u004E\u24C3\uFF2E\u01F8\u0143\u00D1\u1E44\u0147\u1E46\u0145\u1E4A\u1E48\u0220\u019D\uA790\uA7A4]/g
}, {
  base: 'NJ',
  letters: /[\u01CA]/g
}, {
  base: 'Nj',
  letters: /[\u01CB]/g
}, {
  base: 'O',
  letters: /[\u004F\u24C4\uFF2F\u00D2\u00D3\u00D4\u1ED2\u1ED0\u1ED6\u1ED4\u00D5\u1E4C\u022C\u1E4E\u014C\u1E50\u1E52\u014E\u022E\u0230\u00D6\u022A\u1ECE\u0150\u01D1\u020C\u020E\u01A0\u1EDC\u1EDA\u1EE0\u1EDE\u1EE2\u1ECC\u1ED8\u01EA\u01EC\u00D8\u01FE\u0186\u019F\uA74A\uA74C]/g
}, {
  base: 'OI',
  letters: /[\u01A2]/g
}, {
  base: 'OO',
  letters: /[\uA74E]/g
}, {
  base: 'OU',
  letters: /[\u0222]/g
}, {
  base: 'P',
  letters: /[\u0050\u24C5\uFF30\u1E54\u1E56\u01A4\u2C63\uA750\uA752\uA754]/g
}, {
  base: 'Q',
  letters: /[\u0051\u24C6\uFF31\uA756\uA758\u024A]/g
}, {
  base: 'R',
  letters: /[\u0052\u24C7\uFF32\u0154\u1E58\u0158\u0210\u0212\u1E5A\u1E5C\u0156\u1E5E\u024C\u2C64\uA75A\uA7A6\uA782]/g
}, {
  base: 'S',
  letters: /[\u0053\u24C8\uFF33\u1E9E\u015A\u1E64\u015C\u1E60\u0160\u1E66\u1E62\u1E68\u0218\u015E\u2C7E\uA7A8\uA784]/g
}, {
  base: 'T',
  letters: /[\u0054\u24C9\uFF34\u1E6A\u0164\u1E6C\u021A\u0162\u1E70\u1E6E\u0166\u01AC\u01AE\u023E\uA786]/g
}, {
  base: 'TZ',
  letters: /[\uA728]/g
}, {
  base: 'U',
  letters: /[\u0055\u24CA\uFF35\u00D9\u00DA\u00DB\u0168\u1E78\u016A\u1E7A\u016C\u00DC\u01DB\u01D7\u01D5\u01D9\u1EE6\u016E\u0170\u01D3\u0214\u0216\u01AF\u1EEA\u1EE8\u1EEE\u1EEC\u1EF0\u1EE4\u1E72\u0172\u1E76\u1E74\u0244]/g
}, {
  base: 'V',
  letters: /[\u0056\u24CB\uFF36\u1E7C\u1E7E\u01B2\uA75E\u0245]/g
}, {
  base: 'VY',
  letters: /[\uA760]/g
}, {
  base: 'W',
  letters: /[\u0057\u24CC\uFF37\u1E80\u1E82\u0174\u1E86\u1E84\u1E88\u2C72]/g
}, {
  base: 'X',
  letters: /[\u0058\u24CD\uFF38\u1E8A\u1E8C]/g
}, {
  base: 'Y',
  letters: /[\u0059\u24CE\uFF39\u1EF2\u00DD\u0176\u1EF8\u0232\u1E8E\u0178\u1EF6\u1EF4\u01B3\u024E\u1EFE]/g
}, {
  base: 'Z',
  letters: /[\u005A\u24CF\uFF3A\u0179\u1E90\u017B\u017D\u1E92\u1E94\u01B5\u0224\u2C7F\u2C6B\uA762]/g
}, {
  base: 'a',
  letters: /[\u0061\u24D0\uFF41\u1E9A\u00E0\u00E1\u00E2\u1EA7\u1EA5\u1EAB\u1EA9\u00E3\u0101\u0103\u1EB1\u1EAF\u1EB5\u1EB3\u0227\u01E1\u00E4\u01DF\u1EA3\u00E5\u01FB\u01CE\u0201\u0203\u1EA1\u1EAD\u1EB7\u1E01\u0105\u2C65\u0250]/g
}, {
  base: 'aa',
  letters: /[\uA733]/g
}, {
  base: 'ae',
  letters: /[\u00E6\u01FD\u01E3]/g
}, {
  base: 'ao',
  letters: /[\uA735]/g
}, {
  base: 'au',
  letters: /[\uA737]/g
}, {
  base: 'av',
  letters: /[\uA739\uA73B]/g
}, {
  base: 'ay',
  letters: /[\uA73D]/g
}, {
  base: 'b',
  letters: /[\u0062\u24D1\uFF42\u1E03\u1E05\u1E07\u0180\u0183\u0253]/g
}, {
  base: 'c',
  letters: /[\u0063\u24D2\uFF43\u0107\u0109\u010B\u010D\u00E7\u1E09\u0188\u023C\uA73F\u2184]/g
}, {
  base: 'd',
  letters: /[\u0064\u24D3\uFF44\u1E0B\u010F\u1E0D\u1E11\u1E13\u1E0F\u0111\u018C\u0256\u0257\uA77A]/g
}, {
  base: 'dz',
  letters: /[\u01F3\u01C6]/g
}, {
  base: 'e',
  letters: /[\u0065\u24D4\uFF45\u00E8\u00E9\u00EA\u1EC1\u1EBF\u1EC5\u1EC3\u1EBD\u0113\u1E15\u1E17\u0115\u0117\u00EB\u1EBB\u011B\u0205\u0207\u1EB9\u1EC7\u0229\u1E1D\u0119\u1E19\u1E1B\u0247\u025B\u01DD]/g
}, {
  base: 'f',
  letters: /[\u0066\u24D5\uFF46\u1E1F\u0192\uA77C]/g
}, {
  base: 'g',
  letters: /[\u0067\u24D6\uFF47\u01F5\u011D\u1E21\u011F\u0121\u01E7\u0123\u01E5\u0260\uA7A1\u1D79\uA77F]/g
}, {
  base: 'h',
  letters: /[\u0068\u24D7\uFF48\u0125\u1E23\u1E27\u021F\u1E25\u1E29\u1E2B\u1E96\u0127\u2C68\u2C76\u0265]/g
}, {
  base: 'hv',
  letters: /[\u0195]/g
}, {
  base: 'i',
  letters: /[\u0069\u24D8\uFF49\u00EC\u00ED\u00EE\u0129\u012B\u012D\u00EF\u1E2F\u1EC9\u01D0\u0209\u020B\u1ECB\u012F\u1E2D\u0268\u0131]/g
}, {
  base: 'j',
  letters: /[\u006A\u24D9\uFF4A\u0135\u01F0\u0249]/g
}, {
  base: 'k',
  letters: /[\u006B\u24DA\uFF4B\u1E31\u01E9\u1E33\u0137\u1E35\u0199\u2C6A\uA741\uA743\uA745\uA7A3]/g
}, {
  base: 'l',
  letters: /[\u006C\u24DB\uFF4C\u0140\u013A\u013E\u1E37\u1E39\u013C\u1E3D\u1E3B\u017F\u0142\u019A\u026B\u2C61\uA749\uA781\uA747]/g
}, {
  base: 'lj',
  letters: /[\u01C9]/g
}, {
  base: 'm',
  letters: /[\u006D\u24DC\uFF4D\u1E3F\u1E41\u1E43\u0271\u026F]/g
}, {
  base: 'n',
  letters: /[\u006E\u24DD\uFF4E\u01F9\u0144\u00F1\u1E45\u0148\u1E47\u0146\u1E4B\u1E49\u019E\u0272\u0149\uA791\uA7A5]/g
}, {
  base: 'nj',
  letters: /[\u01CC]/g
}, {
  base: 'o',
  letters: /[\u006F\u24DE\uFF4F\u00F2\u00F3\u00F4\u1ED3\u1ED1\u1ED7\u1ED5\u00F5\u1E4D\u022D\u1E4F\u014D\u1E51\u1E53\u014F\u022F\u0231\u00F6\u022B\u1ECF\u0151\u01D2\u020D\u020F\u01A1\u1EDD\u1EDB\u1EE1\u1EDF\u1EE3\u1ECD\u1ED9\u01EB\u01ED\u00F8\u01FF\u0254\uA74B\uA74D\u0275]/g
}, {
  base: 'oi',
  letters: /[\u01A3]/g
}, {
  base: 'ou',
  letters: /[\u0223]/g
}, {
  base: 'oo',
  letters: /[\uA74F]/g
}, {
  base: 'p',
  letters: /[\u0070\u24DF\uFF50\u1E55\u1E57\u01A5\u1D7D\uA751\uA753\uA755]/g
}, {
  base: 'q',
  letters: /[\u0071\u24E0\uFF51\u024B\uA757\uA759]/g
}, {
  base: 'r',
  letters: /[\u0072\u24E1\uFF52\u0155\u1E59\u0159\u0211\u0213\u1E5B\u1E5D\u0157\u1E5F\u024D\u027D\uA75B\uA7A7\uA783]/g
}, {
  base: 's',
  letters: /[\u0073\u24E2\uFF53\u00DF\u015B\u1E65\u015D\u1E61\u0161\u1E67\u1E63\u1E69\u0219\u015F\u023F\uA7A9\uA785\u1E9B]/g
}, {
  base: 't',
  letters: /[\u0074\u24E3\uFF54\u1E6B\u1E97\u0165\u1E6D\u021B\u0163\u1E71\u1E6F\u0167\u01AD\u0288\u2C66\uA787]/g
}, {
  base: 'tz',
  letters: /[\uA729]/g
}, {
  base: 'u',
  letters: /[\u0075\u24E4\uFF55\u00F9\u00FA\u00FB\u0169\u1E79\u016B\u1E7B\u016D\u00FC\u01DC\u01D8\u01D6\u01DA\u1EE7\u016F\u0171\u01D4\u0215\u0217\u01B0\u1EEB\u1EE9\u1EEF\u1EED\u1EF1\u1EE5\u1E73\u0173\u1E77\u1E75\u0289]/g
}, {
  base: 'v',
  letters: /[\u0076\u24E5\uFF56\u1E7D\u1E7F\u028B\uA75F\u028C]/g
}, {
  base: 'vy',
  letters: /[\uA761]/g
}, {
  base: 'w',
  letters: /[\u0077\u24E6\uFF57\u1E81\u1E83\u0175\u1E87\u1E85\u1E98\u1E89\u2C73]/g
}, {
  base: 'x',
  letters: /[\u0078\u24E7\uFF58\u1E8B\u1E8D]/g
}, {
  base: 'y',
  letters: /[\u0079\u24E8\uFF59\u1EF3\u00FD\u0177\u1EF9\u0233\u1E8F\u00FF\u1EF7\u1E99\u1EF5\u01B4\u024F\u1EFF]/g
}, {
  base: 'z',
  letters: /[\u007A\u24E9\uFF5A\u017A\u1E91\u017C\u017E\u1E93\u1E95\u01B6\u0225\u0240\u2C6C\uA763]/g
}];
var stripDiacritics = function stripDiacritics(str) {
  for (var i = 0; i < diacritics.length; i++) {
    str = str.replace(diacritics[i].letters, diacritics[i].base);
  }

  return str;
};

function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

var trimString = function trimString(str) {
  return str.replace(/^\s+|\s+$/g, '');
};

var defaultStringify = function defaultStringify(option) {
  return option.label + " " + option.value;
};

var createFilter = function createFilter(config) {
  return function (option, rawInput) {
    var _ignoreCase$ignoreAcc = _extends({
      ignoreCase: true,
      ignoreAccents: true,
      stringify: defaultStringify,
      trim: true,
      matchFrom: 'any'
    }, config),
        ignoreCase = _ignoreCase$ignoreAcc.ignoreCase,
        ignoreAccents = _ignoreCase$ignoreAcc.ignoreAccents,
        stringify = _ignoreCase$ignoreAcc.stringify,
        trim = _ignoreCase$ignoreAcc.trim,
        matchFrom = _ignoreCase$ignoreAcc.matchFrom;

    var input = trim ? trimString(rawInput) : rawInput;
    var candidate = trim ? trimString(stringify(option)) : stringify(option);

    if (ignoreCase) {
      input = input.toLowerCase();
      candidate = candidate.toLowerCase();
    }

    if (ignoreAccents) {
      input = stripDiacritics(input);
      candidate = stripDiacritics(candidate);
    }

    return matchFrom === 'start' ? candidate.substr(0, input.length) === input : candidate.indexOf(input) > -1;
  };
};

function _extends$1() { _extends$1 = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends$1.apply(this, arguments); }

var _ref =  false ? undefined : {
  name: "1laao21-a11yText",
  styles: "label:a11yText;z-index:9999;border:0;clip:rect(1px, 1px, 1px, 1px);height:1px;width:1px;position:absolute;overflow:hidden;padding:0;white-space:nowrap;",
  map: "/*# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIkExMXlUZXh0LmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQVFNIiwiZmlsZSI6IkExMXlUZXh0LmpzIiwic291cmNlc0NvbnRlbnQiOlsiLy8gQGZsb3dcbi8qKiBAanN4IGpzeCAqL1xuaW1wb3J0IHsgdHlwZSBFbGVtZW50Q29uZmlnIH0gZnJvbSAncmVhY3QnO1xuaW1wb3J0IHsganN4IH0gZnJvbSAnQGVtb3Rpb24vY29yZSc7XG5cbi8vIEFzc2lzdGl2ZSB0ZXh0IHRvIGRlc2NyaWJlIHZpc3VhbCBlbGVtZW50cy4gSGlkZGVuIGZvciBzaWdodGVkIHVzZXJzLlxuY29uc3QgQTExeVRleHQgPSAocHJvcHM6IEVsZW1lbnRDb25maWc8J3NwYW4nPikgPT4gKFxuICAgIDxzcGFuXG4gICAgICBjc3M9e3tcbiAgICAgICAgbGFiZWw6ICdhMTF5VGV4dCcsXG4gICAgICAgIHpJbmRleDogOTk5OSxcbiAgICAgICAgYm9yZGVyOiAwLFxuICAgICAgICBjbGlwOiAncmVjdCgxcHgsIDFweCwgMXB4LCAxcHgpJyxcbiAgICAgICAgaGVpZ2h0OiAxLFxuICAgICAgICB3aWR0aDogMSxcbiAgICAgICAgcG9zaXRpb246ICdhYnNvbHV0ZScsXG4gICAgICAgIG92ZXJmbG93OiAnaGlkZGVuJyxcbiAgICAgICAgcGFkZGluZzogMCxcbiAgICAgICAgd2hpdGVTcGFjZTogJ25vd3JhcCcsXG4gICAgICB9fVxuICAgICAgey4uLnByb3BzfVxuICAgIC8+XG4pO1xuXG5leHBvcnQgZGVmYXVsdCBBMTF5VGV4dDtcbiJdfQ== */"
};

var A11yText = function A11yText(props) {
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_2__["jsx"])("span", _extends$1({
    css: _ref
  }, props));
};

function _extends$2() { _extends$2 = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends$2.apply(this, arguments); }

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }
function DummyInput(_ref) {
  var inProp = _ref.in,
      out = _ref.out,
      onExited = _ref.onExited,
      appear = _ref.appear,
      enter = _ref.enter,
      exit = _ref.exit,
      innerRef = _ref.innerRef,
      emotion = _ref.emotion,
      props = _objectWithoutPropertiesLoose(_ref, ["in", "out", "onExited", "appear", "enter", "exit", "innerRef", "emotion"]);

  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_2__["jsx"])("input", _extends$2({
    ref: innerRef
  }, props, {
    css:
    /*#__PURE__*/
    Object(_emotion_css__WEBPACK_IMPORTED_MODULE_6__["default"])({
      label: 'dummyInput',
      // get rid of any default styles
      background: 0,
      border: 0,
      fontSize: 'inherit',
      outline: 0,
      padding: 0,
      // important! without `width` browsers won't allow focus
      width: 1,
      // remove cursor on desktop
      color: 'transparent',
      // remove cursor on mobile whilst maintaining "scroll into view" behaviour
      left: -100,
      opacity: 0,
      position: 'relative',
      transform: 'scale(0)'
    },  false ? undefined : "/*# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIkR1bW15SW5wdXQuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBbUJNIiwiZmlsZSI6IkR1bW15SW5wdXQuanMiLCJzb3VyY2VzQ29udGVudCI6WyIvLyBAZmxvd1xuLyoqIEBqc3gganN4ICovXG5pbXBvcnQgeyBqc3ggfSBmcm9tICdAZW1vdGlvbi9jb3JlJztcblxuZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24gRHVtbXlJbnB1dCh7XG4gIGluOiBpblByb3AsXG4gIG91dCxcbiAgb25FeGl0ZWQsXG4gIGFwcGVhcixcbiAgZW50ZXIsXG4gIGV4aXQsXG4gIGlubmVyUmVmLFxuICBlbW90aW9uLFxuICAuLi5wcm9wc1xufTogYW55KSB7XG4gIHJldHVybiAoXG4gICAgPGlucHV0XG4gICAgICByZWY9e2lubmVyUmVmfVxuICAgICAgey4uLnByb3BzfVxuICAgICAgY3NzPXt7XG4gICAgICAgIGxhYmVsOiAnZHVtbXlJbnB1dCcsXG4gICAgICAgIC8vIGdldCByaWQgb2YgYW55IGRlZmF1bHQgc3R5bGVzXG4gICAgICAgIGJhY2tncm91bmQ6IDAsXG4gICAgICAgIGJvcmRlcjogMCxcbiAgICAgICAgZm9udFNpemU6ICdpbmhlcml0JyxcbiAgICAgICAgb3V0bGluZTogMCxcbiAgICAgICAgcGFkZGluZzogMCxcbiAgICAgICAgLy8gaW1wb3J0YW50ISB3aXRob3V0IGB3aWR0aGAgYnJvd3NlcnMgd29uJ3QgYWxsb3cgZm9jdXNcbiAgICAgICAgd2lkdGg6IDEsXG5cbiAgICAgICAgLy8gcmVtb3ZlIGN1cnNvciBvbiBkZXNrdG9wXG4gICAgICAgIGNvbG9yOiAndHJhbnNwYXJlbnQnLFxuXG4gICAgICAgIC8vIHJlbW92ZSBjdXJzb3Igb24gbW9iaWxlIHdoaWxzdCBtYWludGFpbmluZyBcInNjcm9sbCBpbnRvIHZpZXdcIiBiZWhhdmlvdXJcbiAgICAgICAgbGVmdDogLTEwMCxcbiAgICAgICAgb3BhY2l0eTogMCxcbiAgICAgICAgcG9zaXRpb246ICdyZWxhdGl2ZScsXG4gICAgICAgIHRyYW5zZm9ybTogJ3NjYWxlKDApJyxcbiAgICAgIH19XG4gICAgLz5cbiAgKTtcbn1cbiJdfQ== */")
  }));
}

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }

var NodeResolver =
/*#__PURE__*/
function (_Component) {
  _inheritsLoose(NodeResolver, _Component);

  function NodeResolver() {
    return _Component.apply(this, arguments) || this;
  }

  var _proto = NodeResolver.prototype;

  _proto.componentDidMount = function componentDidMount() {
    this.props.innerRef(Object(react_dom__WEBPACK_IMPORTED_MODULE_3__["findDOMNode"])(this));
  };

  _proto.componentWillUnmount = function componentWillUnmount() {
    this.props.innerRef(null);
  };

  _proto.render = function render() {
    return this.props.children;
  };

  return NodeResolver;
}(react__WEBPACK_IMPORTED_MODULE_0__["Component"]);

var STYLE_KEYS = ['boxSizing', 'height', 'overflow', 'paddingRight', 'position'];
var LOCK_STYLES = {
  boxSizing: 'border-box',
  // account for possible declaration `width: 100%;` on body
  overflow: 'hidden',
  position: 'relative',
  height: '100%'
};

function preventTouchMove(e) {
  e.preventDefault();
}
function allowTouchMove(e) {
  e.stopPropagation();
}
function preventInertiaScroll() {
  var top = this.scrollTop;
  var totalScroll = this.scrollHeight;
  var currentScroll = top + this.offsetHeight;

  if (top === 0) {
    this.scrollTop = 1;
  } else if (currentScroll === totalScroll) {
    this.scrollTop = top - 1;
  }
} // `ontouchstart` check works on most browsers
// `maxTouchPoints` works on IE10/11 and Surface

function isTouchDevice() {
  return 'ontouchstart' in window || navigator.maxTouchPoints;
}

function _inheritsLoose$1(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }
var canUseDOM = !!( window.document && window.document.createElement);
var activeScrollLocks = 0;

var ScrollLock =
/*#__PURE__*/
function (_Component) {
  _inheritsLoose$1(ScrollLock, _Component);

  function ScrollLock() {
    var _this;

    for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
      args[_key] = arguments[_key];
    }

    _this = _Component.call.apply(_Component, [this].concat(args)) || this;
    _this.originalStyles = {};
    _this.listenerOptions = {
      capture: false,
      passive: false
    };
    return _this;
  }

  var _proto = ScrollLock.prototype;

  _proto.componentDidMount = function componentDidMount() {
    var _this2 = this;

    if (!canUseDOM) return;
    var _this$props = this.props,
        accountForScrollbars = _this$props.accountForScrollbars,
        touchScrollTarget = _this$props.touchScrollTarget;
    var target = document.body;
    var targetStyle = target && target.style;

    if (accountForScrollbars) {
      // store any styles already applied to the body
      STYLE_KEYS.forEach(function (key) {
        var val = targetStyle && targetStyle[key];
        _this2.originalStyles[key] = val;
      });
    } // apply the lock styles and padding if this is the first scroll lock


    if (accountForScrollbars && activeScrollLocks < 1) {
      var currentPadding = parseInt(this.originalStyles.paddingRight, 10) || 0;
      var clientWidth = document.body ? document.body.clientWidth : 0;
      var adjustedPadding = window.innerWidth - clientWidth + currentPadding || 0;
      Object.keys(LOCK_STYLES).forEach(function (key) {
        var val = LOCK_STYLES[key];

        if (targetStyle) {
          targetStyle[key] = val;
        }
      });

      if (targetStyle) {
        targetStyle.paddingRight = adjustedPadding + "px";
      }
    } // account for touch devices


    if (target && isTouchDevice()) {
      // Mobile Safari ignores { overflow: hidden } declaration on the body.
      target.addEventListener('touchmove', preventTouchMove, this.listenerOptions); // Allow scroll on provided target

      if (touchScrollTarget) {
        touchScrollTarget.addEventListener('touchstart', preventInertiaScroll, this.listenerOptions);
        touchScrollTarget.addEventListener('touchmove', allowTouchMove, this.listenerOptions);
      }
    } // increment active scroll locks


    activeScrollLocks += 1;
  };

  _proto.componentWillUnmount = function componentWillUnmount() {
    var _this3 = this;

    if (!canUseDOM) return;
    var _this$props2 = this.props,
        accountForScrollbars = _this$props2.accountForScrollbars,
        touchScrollTarget = _this$props2.touchScrollTarget;
    var target = document.body;
    var targetStyle = target && target.style; // safely decrement active scroll locks

    activeScrollLocks = Math.max(activeScrollLocks - 1, 0); // reapply original body styles, if any

    if (accountForScrollbars && activeScrollLocks < 1) {
      STYLE_KEYS.forEach(function (key) {
        var val = _this3.originalStyles[key];

        if (targetStyle) {
          targetStyle[key] = val;
        }
      });
    } // remove touch listeners


    if (target && isTouchDevice()) {
      target.removeEventListener('touchmove', preventTouchMove, this.listenerOptions);

      if (touchScrollTarget) {
        touchScrollTarget.removeEventListener('touchstart', preventInertiaScroll, this.listenerOptions);
        touchScrollTarget.removeEventListener('touchmove', allowTouchMove, this.listenerOptions);
      }
    }
  };

  _proto.render = function render() {
    return null;
  };

  return ScrollLock;
}(react__WEBPACK_IMPORTED_MODULE_0__["Component"]);

ScrollLock.defaultProps = {
  accountForScrollbars: true
};

function _inheritsLoose$2(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }

var _ref$1 =  false ? undefined : {
  name: "1dsbpcp",
  styles: "position:fixed;left:0;bottom:0;right:0;top:0;",
  map: "/*# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIlNjcm9sbEJsb2NrLmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQTZEVSIsImZpbGUiOiJTY3JvbGxCbG9jay5qcyIsInNvdXJjZXNDb250ZW50IjpbIi8vIEBmbG93XG4vKiogQGpzeCBqc3ggKi9cbmltcG9ydCB7IFB1cmVDb21wb25lbnQsIHR5cGUgRWxlbWVudCB9IGZyb20gJ3JlYWN0JztcbmltcG9ydCB7IGpzeCB9IGZyb20gJ0BlbW90aW9uL2NvcmUnO1xuaW1wb3J0IE5vZGVSZXNvbHZlciBmcm9tICcuL05vZGVSZXNvbHZlcic7XG5pbXBvcnQgU2Nyb2xsTG9jayBmcm9tICcuL1Njcm9sbExvY2svaW5kZXgnO1xuXG50eXBlIFByb3BzID0ge1xuICBjaGlsZHJlbjogRWxlbWVudDwqPixcbiAgaXNFbmFibGVkOiBib29sZWFuLFxufTtcbnR5cGUgU3RhdGUgPSB7XG4gIHRvdWNoU2Nyb2xsVGFyZ2V0OiBIVE1MRWxlbWVudCB8IG51bGwsXG59O1xuXG4vLyBOT1RFOlxuLy8gV2Ugc2hvdWxkbid0IG5lZWQgdGhpcyBhZnRlciB1cGRhdGluZyB0byBSZWFjdCB2MTYuMy4wLCB3aGljaCBpbnRyb2R1Y2VzOlxuLy8gLSBjcmVhdGVSZWYoKSBodHRwczovL3JlYWN0anMub3JnL2RvY3MvcmVhY3QtYXBpLmh0bWwjcmVhY3RjcmVhdGVyZWZcbi8vIC0gZm9yd2FyZFJlZigpIGh0dHBzOi8vcmVhY3Rqcy5vcmcvZG9jcy9yZWFjdC1hcGkuaHRtbCNyZWFjdGZvcndhcmRyZWZcblxuZXhwb3J0IGRlZmF1bHQgY2xhc3MgU2Nyb2xsQmxvY2sgZXh0ZW5kcyBQdXJlQ29tcG9uZW50PFByb3BzLCBTdGF0ZT4ge1xuICBzdGF0ZSA9IHsgdG91Y2hTY3JvbGxUYXJnZXQ6IG51bGwgfTtcblxuICAvLyBtdXN0IGJlIGluIHN0YXRlIHRvIHRyaWdnZXIgYSByZS1yZW5kZXIsIG9ubHkgcnVucyBvbmNlIHBlciBpbnN0YW5jZVxuICBnZXRTY3JvbGxUYXJnZXQgPSAocmVmOiBIVE1MRWxlbWVudCkgPT4ge1xuICAgIGlmIChyZWYgPT09IHRoaXMuc3RhdGUudG91Y2hTY3JvbGxUYXJnZXQpIHJldHVybjtcbiAgICB0aGlzLnNldFN0YXRlKHsgdG91Y2hTY3JvbGxUYXJnZXQ6IHJlZiB9KTtcbiAgfTtcblxuICAvLyB0aGlzIHdpbGwgY2xvc2UgdGhlIG1lbnUgd2hlbiBhIHVzZXIgY2xpY2tzIG91dHNpZGVcbiAgYmx1clNlbGVjdElucHV0ID0gKCkgPT4ge1xuICAgIGlmIChkb2N1bWVudC5hY3RpdmVFbGVtZW50KSB7XG4gICAgICBkb2N1bWVudC5hY3RpdmVFbGVtZW50LmJsdXIoKTtcbiAgICB9XG4gIH07XG5cbiAgcmVuZGVyKCkge1xuICAgIGNvbnN0IHsgY2hpbGRyZW4sIGlzRW5hYmxlZCB9ID0gdGhpcy5wcm9wcztcbiAgICBjb25zdCB7IHRvdWNoU2Nyb2xsVGFyZ2V0IH0gPSB0aGlzLnN0YXRlO1xuXG4gICAgLy8gYmFpbCBlYXJseSBpZiBub3QgZW5hYmxlZFxuICAgIGlmICghaXNFbmFibGVkKSByZXR1cm4gY2hpbGRyZW47XG5cbiAgICAvKlxuICAgICAqIERpdlxuICAgICAqIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuICAgICAqIGJsb2NrcyBzY3JvbGxpbmcgb24gbm9uLWJvZHkgZWxlbWVudHMgYmVoaW5kIHRoZSBtZW51XG5cbiAgICAgKiBOb2RlUmVzb2x2ZXJcbiAgICAgKiAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbiAgICAgKiB3ZSBuZWVkIGEgcmVmZXJlbmNlIHRvIHRoZSBzY3JvbGxhYmxlIGVsZW1lbnQgdG8gXCJ1bmxvY2tcIiBzY3JvbGwgb25cbiAgICAgKiBtb2JpbGUgZGV2aWNlc1xuXG4gICAgICogU2Nyb2xsTG9ja1xuICAgICAqIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuICAgICAqIGFjdHVhbGx5IGRvZXMgdGhlIHNjcm9sbCBsb2NraW5nXG4gICAgICovXG4gICAgcmV0dXJuIChcbiAgICAgIDxkaXY+XG4gICAgICAgIDxkaXZcbiAgICAgICAgICBvbkNsaWNrPXt0aGlzLmJsdXJTZWxlY3RJbnB1dH1cbiAgICAgICAgICBjc3M9e3sgcG9zaXRpb246ICdmaXhlZCcsIGxlZnQ6IDAsIGJvdHRvbTogMCwgcmlnaHQ6IDAsIHRvcDogMCB9fVxuICAgICAgICAvPlxuICAgICAgICA8Tm9kZVJlc29sdmVyIGlubmVyUmVmPXt0aGlzLmdldFNjcm9sbFRhcmdldH0+e2NoaWxkcmVufTwvTm9kZVJlc29sdmVyPlxuICAgICAgICB7dG91Y2hTY3JvbGxUYXJnZXQgPyAoXG4gICAgICAgICAgPFNjcm9sbExvY2sgdG91Y2hTY3JvbGxUYXJnZXQ9e3RvdWNoU2Nyb2xsVGFyZ2V0fSAvPlxuICAgICAgICApIDogbnVsbH1cbiAgICAgIDwvZGl2PlxuICAgICk7XG4gIH1cbn1cbiJdfQ== */"
};

// NOTE:
// We shouldn't need this after updating to React v16.3.0, which introduces:
// - createRef() https://reactjs.org/docs/react-api.html#reactcreateref
// - forwardRef() https://reactjs.org/docs/react-api.html#reactforwardref
var ScrollBlock =
/*#__PURE__*/
function (_PureComponent) {
  _inheritsLoose$2(ScrollBlock, _PureComponent);

  function ScrollBlock() {
    var _this;

    for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
      args[_key] = arguments[_key];
    }

    _this = _PureComponent.call.apply(_PureComponent, [this].concat(args)) || this;
    _this.state = {
      touchScrollTarget: null
    };

    _this.getScrollTarget = function (ref) {
      if (ref === _this.state.touchScrollTarget) return;

      _this.setState({
        touchScrollTarget: ref
      });
    };

    _this.blurSelectInput = function () {
      if (document.activeElement) {
        document.activeElement.blur();
      }
    };

    return _this;
  }

  var _proto = ScrollBlock.prototype;

  _proto.render = function render() {
    var _this$props = this.props,
        children = _this$props.children,
        isEnabled = _this$props.isEnabled;
    var touchScrollTarget = this.state.touchScrollTarget; // bail early if not enabled

    if (!isEnabled) return children;
    /*
     * Div
     * ------------------------------
     * blocks scrolling on non-body elements behind the menu
      * NodeResolver
     * ------------------------------
     * we need a reference to the scrollable element to "unlock" scroll on
     * mobile devices
      * ScrollLock
     * ------------------------------
     * actually does the scroll locking
     */

    return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_2__["jsx"])("div", null, Object(_emotion_core__WEBPACK_IMPORTED_MODULE_2__["jsx"])("div", {
      onClick: this.blurSelectInput,
      css: _ref$1
    }), Object(_emotion_core__WEBPACK_IMPORTED_MODULE_2__["jsx"])(NodeResolver, {
      innerRef: this.getScrollTarget
    }, children), touchScrollTarget ? Object(_emotion_core__WEBPACK_IMPORTED_MODULE_2__["jsx"])(ScrollLock, {
      touchScrollTarget: touchScrollTarget
    }) : null);
  };

  return ScrollBlock;
}(react__WEBPACK_IMPORTED_MODULE_0__["PureComponent"]);

function _objectWithoutPropertiesLoose$1(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _inheritsLoose$3(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }

var ScrollCaptor =
/*#__PURE__*/
function (_Component) {
  _inheritsLoose$3(ScrollCaptor, _Component);

  function ScrollCaptor() {
    var _this;

    for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
      args[_key] = arguments[_key];
    }

    _this = _Component.call.apply(_Component, [this].concat(args)) || this;
    _this.isBottom = false;
    _this.isTop = false;
    _this.scrollTarget = void 0;
    _this.touchStart = void 0;

    _this.cancelScroll = function (event) {
      event.preventDefault();
      event.stopPropagation();
    };

    _this.handleEventDelta = function (event, delta) {
      var _this$props = _this.props,
          onBottomArrive = _this$props.onBottomArrive,
          onBottomLeave = _this$props.onBottomLeave,
          onTopArrive = _this$props.onTopArrive,
          onTopLeave = _this$props.onTopLeave;
      var _this$scrollTarget = _this.scrollTarget,
          scrollTop = _this$scrollTarget.scrollTop,
          scrollHeight = _this$scrollTarget.scrollHeight,
          clientHeight = _this$scrollTarget.clientHeight;
      var target = _this.scrollTarget;
      var isDeltaPositive = delta > 0;
      var availableScroll = scrollHeight - clientHeight - scrollTop;
      var shouldCancelScroll = false; // reset bottom/top flags

      if (availableScroll > delta && _this.isBottom) {
        if (onBottomLeave) onBottomLeave(event);
        _this.isBottom = false;
      }

      if (isDeltaPositive && _this.isTop) {
        if (onTopLeave) onTopLeave(event);
        _this.isTop = false;
      } // bottom limit


      if (isDeltaPositive && delta > availableScroll) {
        if (onBottomArrive && !_this.isBottom) {
          onBottomArrive(event);
        }

        target.scrollTop = scrollHeight;
        shouldCancelScroll = true;
        _this.isBottom = true; // top limit
      } else if (!isDeltaPositive && -delta > scrollTop) {
        if (onTopArrive && !_this.isTop) {
          onTopArrive(event);
        }

        target.scrollTop = 0;
        shouldCancelScroll = true;
        _this.isTop = true;
      } // cancel scroll


      if (shouldCancelScroll) {
        _this.cancelScroll(event);
      }
    };

    _this.onWheel = function (event) {
      _this.handleEventDelta(event, event.deltaY);
    };

    _this.onTouchStart = function (event) {
      // set touch start so we can calculate touchmove delta
      _this.touchStart = event.changedTouches[0].clientY;
    };

    _this.onTouchMove = function (event) {
      var deltaY = _this.touchStart - event.changedTouches[0].clientY;

      _this.handleEventDelta(event, deltaY);
    };

    _this.getScrollTarget = function (ref) {
      _this.scrollTarget = ref;
    };

    return _this;
  }

  var _proto = ScrollCaptor.prototype;

  _proto.componentDidMount = function componentDidMount() {
    this.startListening(this.scrollTarget);
  };

  _proto.componentWillUnmount = function componentWillUnmount() {
    this.stopListening(this.scrollTarget);
  };

  _proto.startListening = function startListening(el) {
    // bail early if no element is available to attach to
    if (!el) return; // all the if statements are to appease Flow 😢

    if (typeof el.addEventListener === 'function') {
      el.addEventListener('wheel', this.onWheel, false);
    }

    if (typeof el.addEventListener === 'function') {
      el.addEventListener('touchstart', this.onTouchStart, false);
    }

    if (typeof el.addEventListener === 'function') {
      el.addEventListener('touchmove', this.onTouchMove, false);
    }
  };

  _proto.stopListening = function stopListening(el) {
    // all the if statements are to appease Flow 😢
    if (typeof el.removeEventListener === 'function') {
      el.removeEventListener('wheel', this.onWheel, false);
    }

    if (typeof el.removeEventListener === 'function') {
      el.removeEventListener('touchstart', this.onTouchStart, false);
    }

    if (typeof el.removeEventListener === 'function') {
      el.removeEventListener('touchmove', this.onTouchMove, false);
    }
  };

  _proto.render = function render() {
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(NodeResolver, {
      innerRef: this.getScrollTarget
    }, this.props.children);
  };

  return ScrollCaptor;
}(react__WEBPACK_IMPORTED_MODULE_0__["Component"]);

function ScrollCaptorSwitch(_ref) {
  var _ref$isEnabled = _ref.isEnabled,
      isEnabled = _ref$isEnabled === void 0 ? true : _ref$isEnabled,
      props = _objectWithoutPropertiesLoose$1(_ref, ["isEnabled"]);

  return isEnabled ? react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(ScrollCaptor, props) : props.children;
}

var instructionsAriaMessage = function instructionsAriaMessage(event, context) {
  if (context === void 0) {
    context = {};
  }

  var _context = context,
      isSearchable = _context.isSearchable,
      isMulti = _context.isMulti,
      label = _context.label,
      isDisabled = _context.isDisabled;

  switch (event) {
    case 'menu':
      return "Use Up and Down to choose options" + (isDisabled ? '' : ', press Enter to select the currently focused option') + ", press Escape to exit the menu, press Tab to select the option and exit the menu.";

    case 'input':
      return (label ? label : 'Select') + " is focused " + (isSearchable ? ',type to refine list' : '') + ", press Down to open the menu, " + (isMulti ? ' press left to focus selected values' : '');

    case 'value':
      return 'Use left and right to toggle between focused values, press Backspace to remove the currently focused value';
  }
};
var valueEventAriaMessage = function valueEventAriaMessage(event, context) {
  var value = context.value,
      isDisabled = context.isDisabled;
  if (!value) return;

  switch (event) {
    case 'deselect-option':
    case 'pop-value':
    case 'remove-value':
      return "option " + value + ", deselected.";

    case 'select-option':
      return isDisabled ? "option " + value + " is disabled. Select another option." : "option " + value + ", selected.";
  }
};
var valueFocusAriaMessage = function valueFocusAriaMessage(_ref) {
  var focusedValue = _ref.focusedValue,
      getOptionLabel = _ref.getOptionLabel,
      selectValue = _ref.selectValue;
  return "value " + getOptionLabel(focusedValue) + " focused, " + (selectValue.indexOf(focusedValue) + 1) + " of " + selectValue.length + ".";
};
var optionFocusAriaMessage = function optionFocusAriaMessage(_ref2) {
  var focusedOption = _ref2.focusedOption,
      getOptionLabel = _ref2.getOptionLabel,
      options = _ref2.options;
  return "option " + getOptionLabel(focusedOption) + " focused" + (focusedOption.isDisabled ? ' disabled' : '') + ", " + (options.indexOf(focusedOption) + 1) + " of " + options.length + ".";
};
var resultsAriaMessage = function resultsAriaMessage(_ref3) {
  var inputValue = _ref3.inputValue,
      screenReaderMessage = _ref3.screenReaderMessage;
  return "" + screenReaderMessage + (inputValue ? ' for search term ' + inputValue : '') + ".";
};

var formatGroupLabel = function formatGroupLabel(group) {
  return group.label;
};
var getOptionLabel = function getOptionLabel(option) {
  return option.label;
};
var getOptionValue = function getOptionValue(option) {
  return option.value;
};
var isOptionDisabled = function isOptionDisabled(option) {
  return !!option.isDisabled;
};

function _extends$3() { _extends$3 = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends$3.apply(this, arguments); }
var defaultStyles = {
  clearIndicator: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["c"],
  container: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["a"],
  control: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["b"],
  dropdownIndicator: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["d"],
  group: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["g"],
  groupHeading: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["e"],
  indicatorsContainer: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["i"],
  indicatorSeparator: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["f"],
  input: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["h"],
  loadingIndicator: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["l"],
  loadingMessage: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["j"],
  menu: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["m"],
  menuList: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["k"],
  menuPortal: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["n"],
  multiValue: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["o"],
  multiValueLabel: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["p"],
  multiValueRemove: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["q"],
  noOptionsMessage: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["r"],
  option: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["s"],
  placeholder: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["t"],
  singleValue: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["u"],
  valueContainer: _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["v"]
}; // Merge Utility
// Allows consumers to extend a base Select with additional styles

function mergeStyles(source, target) {
  if (target === void 0) {
    target = {};
  }

  // initialize with source styles
  var styles = _extends$3({}, source); // massage in target styles


  Object.keys(target).forEach(function (key) {
    if (source[key]) {
      styles[key] = function (rsCss, props) {
        return target[key](source[key](rsCss, props), props);
      };
    } else {
      styles[key] = target[key];
    }
  });
  return styles;
}

var colors = {
  primary: '#2684FF',
  primary75: '#4C9AFF',
  primary50: '#B2D4FF',
  primary25: '#DEEBFF',
  danger: '#DE350B',
  dangerLight: '#FFBDAD',
  neutral0: 'hsl(0, 0%, 100%)',
  neutral5: 'hsl(0, 0%, 95%)',
  neutral10: 'hsl(0, 0%, 90%)',
  neutral20: 'hsl(0, 0%, 80%)',
  neutral30: 'hsl(0, 0%, 70%)',
  neutral40: 'hsl(0, 0%, 60%)',
  neutral50: 'hsl(0, 0%, 50%)',
  neutral60: 'hsl(0, 0%, 40%)',
  neutral70: 'hsl(0, 0%, 30%)',
  neutral80: 'hsl(0, 0%, 20%)',
  neutral90: 'hsl(0, 0%, 10%)'
};
var borderRadius = 4; // Used to calculate consistent margin/padding on elements

var baseUnit = 4; // The minimum height of the control

var controlHeight = 38; // The amount of space between the control and menu */

var menuGutter = baseUnit * 2;
var spacing = {
  baseUnit: baseUnit,
  controlHeight: controlHeight,
  menuGutter: menuGutter
};
var defaultTheme = {
  borderRadius: borderRadius,
  colors: colors,
  spacing: spacing
};

function _objectWithoutPropertiesLoose$2(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _extends$4() { _extends$4 = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends$4.apply(this, arguments); }

function _inheritsLoose$4(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }

function _assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }
var defaultProps = {
  backspaceRemovesValue: true,
  blurInputOnSelect: Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["i"])(),
  captureMenuScroll: !Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["i"])(),
  closeMenuOnSelect: true,
  closeMenuOnScroll: false,
  components: {},
  controlShouldRenderValue: true,
  escapeClearsValue: false,
  filterOption: createFilter(),
  formatGroupLabel: formatGroupLabel,
  getOptionLabel: getOptionLabel,
  getOptionValue: getOptionValue,
  isDisabled: false,
  isLoading: false,
  isMulti: false,
  isRtl: false,
  isSearchable: true,
  isOptionDisabled: isOptionDisabled,
  loadingMessage: function loadingMessage() {
    return 'Loading...';
  },
  maxMenuHeight: 300,
  minMenuHeight: 140,
  menuIsOpen: false,
  menuPlacement: 'bottom',
  menuPosition: 'absolute',
  menuShouldBlockScroll: false,
  menuShouldScrollIntoView: !Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["d"])(),
  noOptionsMessage: function noOptionsMessage() {
    return 'No options';
  },
  openMenuOnFocus: false,
  openMenuOnClick: true,
  options: [],
  pageSize: 5,
  placeholder: 'Select...',
  screenReaderStatus: function screenReaderStatus(_ref) {
    var count = _ref.count;
    return count + " result" + (count !== 1 ? 's' : '') + " available";
  },
  styles: {},
  tabIndex: '0',
  tabSelectsValue: true
};
var instanceId = 1;

var Select =
/*#__PURE__*/
function (_Component) {
  _inheritsLoose$4(Select, _Component);

  // Misc. Instance Properties
  // ------------------------------
  // TODO
  // Refs
  // ------------------------------
  // Lifecycle
  // ------------------------------
  function Select(_props) {
    var _this;

    _this = _Component.call(this, _props) || this;
    _this.state = {
      ariaLiveSelection: '',
      ariaLiveContext: '',
      focusedOption: null,
      focusedValue: null,
      inputIsHidden: false,
      isFocused: false,
      menuOptions: {
        render: [],
        focusable: []
      },
      selectValue: []
    };
    _this.blockOptionHover = false;
    _this.isComposing = false;
    _this.clearFocusValueOnUpdate = false;
    _this.commonProps = void 0;
    _this.components = void 0;
    _this.hasGroups = false;
    _this.initialTouchX = 0;
    _this.initialTouchY = 0;
    _this.inputIsHiddenAfterUpdate = void 0;
    _this.instancePrefix = '';
    _this.openAfterFocus = false;
    _this.scrollToFocusedOptionOnUpdate = false;
    _this.userIsDragging = void 0;
    _this.controlRef = null;

    _this.getControlRef = function (ref) {
      _this.controlRef = ref;
    };

    _this.focusedOptionRef = null;

    _this.getFocusedOptionRef = function (ref) {
      _this.focusedOptionRef = ref;
    };

    _this.menuListRef = null;

    _this.getMenuListRef = function (ref) {
      _this.menuListRef = ref;
    };

    _this.inputRef = null;

    _this.getInputRef = function (ref) {
      _this.inputRef = ref;
    };

    _this.cacheComponents = function (components) {
      _this.components = Object(_index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["w"])({
        components: components
      });
    };

    _this.focus = _this.focusInput;
    _this.blur = _this.blurInput;

    _this.onChange = function (newValue, actionMeta) {
      var _this$props = _this.props,
          onChange = _this$props.onChange,
          name = _this$props.name;
      onChange(newValue, _extends$4({}, actionMeta, {
        name: name
      }));
    };

    _this.setValue = function (newValue, action, option) {
      if (action === void 0) {
        action = 'set-value';
      }

      var _this$props2 = _this.props,
          closeMenuOnSelect = _this$props2.closeMenuOnSelect,
          isMulti = _this$props2.isMulti;

      _this.onInputChange('', {
        action: 'set-value'
      });

      if (closeMenuOnSelect) {
        _this.inputIsHiddenAfterUpdate = !isMulti;

        _this.onMenuClose();
      } // when the select value should change, we should reset focusedValue


      _this.clearFocusValueOnUpdate = true;

      _this.onChange(newValue, {
        action: action,
        option: option
      });
    };

    _this.selectOption = function (newValue) {
      var _this$props3 = _this.props,
          blurInputOnSelect = _this$props3.blurInputOnSelect,
          isMulti = _this$props3.isMulti;
      var selectValue = _this.state.selectValue;

      if (isMulti) {
        if (_this.isOptionSelected(newValue, selectValue)) {
          var candidate = _this.getOptionValue(newValue);

          _this.setValue(selectValue.filter(function (i) {
            return _this.getOptionValue(i) !== candidate;
          }), 'deselect-option', newValue);

          _this.announceAriaLiveSelection({
            event: 'deselect-option',
            context: {
              value: _this.getOptionLabel(newValue)
            }
          });
        } else {
          if (!_this.isOptionDisabled(newValue, selectValue)) {
            _this.setValue([].concat(selectValue, [newValue]), 'select-option', newValue);

            _this.announceAriaLiveSelection({
              event: 'select-option',
              context: {
                value: _this.getOptionLabel(newValue)
              }
            });
          } else {
            // announce that option is disabled
            _this.announceAriaLiveSelection({
              event: 'select-option',
              context: {
                value: _this.getOptionLabel(newValue),
                isDisabled: true
              }
            });
          }
        }
      } else {
        if (!_this.isOptionDisabled(newValue, selectValue)) {
          _this.setValue(newValue, 'select-option');

          _this.announceAriaLiveSelection({
            event: 'select-option',
            context: {
              value: _this.getOptionLabel(newValue)
            }
          });
        } else {
          // announce that option is disabled
          _this.announceAriaLiveSelection({
            event: 'select-option',
            context: {
              value: _this.getOptionLabel(newValue),
              isDisabled: true
            }
          });
        }
      }

      if (blurInputOnSelect) {
        _this.blurInput();
      }
    };

    _this.removeValue = function (removedValue) {
      var selectValue = _this.state.selectValue;

      var candidate = _this.getOptionValue(removedValue);

      var newValue = selectValue.filter(function (i) {
        return _this.getOptionValue(i) !== candidate;
      });

      _this.onChange(newValue.length ? newValue : null, {
        action: 'remove-value',
        removedValue: removedValue
      });

      _this.announceAriaLiveSelection({
        event: 'remove-value',
        context: {
          value: removedValue ? _this.getOptionLabel(removedValue) : ''
        }
      });

      _this.focusInput();
    };

    _this.clearValue = function () {
      var isMulti = _this.props.isMulti;

      _this.onChange(isMulti ? [] : null, {
        action: 'clear'
      });
    };

    _this.popValue = function () {
      var selectValue = _this.state.selectValue;
      var lastSelectedValue = selectValue[selectValue.length - 1];
      var newValue = selectValue.slice(0, selectValue.length - 1);

      _this.announceAriaLiveSelection({
        event: 'pop-value',
        context: {
          value: lastSelectedValue ? _this.getOptionLabel(lastSelectedValue) : ''
        }
      });

      _this.onChange(newValue.length ? newValue : null, {
        action: 'pop-value',
        removedValue: lastSelectedValue
      });
    };

    _this.getOptionLabel = function (data) {
      return _this.props.getOptionLabel(data);
    };

    _this.getOptionValue = function (data) {
      return _this.props.getOptionValue(data);
    };

    _this.getStyles = function (key, props) {
      var base = defaultStyles[key](props);
      base.boxSizing = 'border-box';
      var custom = _this.props.styles[key];
      return custom ? custom(base, props) : base;
    };

    _this.getElementId = function (element) {
      return _this.instancePrefix + "-" + element;
    };

    _this.getActiveDescendentId = function () {
      var menuIsOpen = _this.props.menuIsOpen;
      var _this$state = _this.state,
          menuOptions = _this$state.menuOptions,
          focusedOption = _this$state.focusedOption;
      if (!focusedOption || !menuIsOpen) return undefined;
      var index = menuOptions.focusable.indexOf(focusedOption);
      var option = menuOptions.render[index];
      return option && option.key;
    };

    _this.announceAriaLiveSelection = function (_ref2) {
      var event = _ref2.event,
          context = _ref2.context;

      _this.setState({
        ariaLiveSelection: valueEventAriaMessage(event, context)
      });
    };

    _this.announceAriaLiveContext = function (_ref3) {
      var event = _ref3.event,
          context = _ref3.context;

      _this.setState({
        ariaLiveContext: instructionsAriaMessage(event, _extends$4({}, context, {
          label: _this.props['aria-label']
        }))
      });
    };

    _this.onMenuMouseDown = function (event) {
      if (event.button !== 0) {
        return;
      }

      event.stopPropagation();
      event.preventDefault();

      _this.focusInput();
    };

    _this.onMenuMouseMove = function (event) {
      _this.blockOptionHover = false;
    };

    _this.onControlMouseDown = function (event) {
      var openMenuOnClick = _this.props.openMenuOnClick;

      if (!_this.state.isFocused) {
        if (openMenuOnClick) {
          _this.openAfterFocus = true;
        }

        _this.focusInput();
      } else if (!_this.props.menuIsOpen) {
        if (openMenuOnClick) {
          _this.openMenu('first');
        }
      } else {
        if ( // $FlowFixMe
        event.target.tagName !== 'INPUT' && event.target.tagName !== 'TEXTAREA') {
          _this.onMenuClose();
        }
      }

      if ( // $FlowFixMe
      event.target.tagName !== 'INPUT' && event.target.tagName !== 'TEXTAREA') {
        event.preventDefault();
      }
    };

    _this.onDropdownIndicatorMouseDown = function (event) {
      // ignore mouse events that weren't triggered by the primary button
      if (event && event.type === 'mousedown' && event.button !== 0) {
        return;
      }

      if (_this.props.isDisabled) return;
      var _this$props4 = _this.props,
          isMulti = _this$props4.isMulti,
          menuIsOpen = _this$props4.menuIsOpen;

      _this.focusInput();

      if (menuIsOpen) {
        _this.inputIsHiddenAfterUpdate = !isMulti;

        _this.onMenuClose();
      } else {
        _this.openMenu('first');
      }

      event.preventDefault();
      event.stopPropagation();
    };

    _this.onClearIndicatorMouseDown = function (event) {
      // ignore mouse events that weren't triggered by the primary button
      if (event && event.type === 'mousedown' && event.button !== 0) {
        return;
      }

      _this.clearValue();

      event.stopPropagation();
      _this.openAfterFocus = false;

      if (event.type === 'touchend') {
        _this.focusInput();
      } else {
        setTimeout(function () {
          return _this.focusInput();
        });
      }
    };

    _this.onScroll = function (event) {
      if (typeof _this.props.closeMenuOnScroll === 'boolean') {
        if (event.target instanceof HTMLElement && Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["j"])(event.target)) {
          _this.props.onMenuClose();
        }
      } else if (typeof _this.props.closeMenuOnScroll === 'function') {
        if (_this.props.closeMenuOnScroll(event)) {
          _this.props.onMenuClose();
        }
      }
    };

    _this.onCompositionStart = function () {
      _this.isComposing = true;
    };

    _this.onCompositionEnd = function () {
      _this.isComposing = false;
    };

    _this.onTouchStart = function (_ref4) {
      var touches = _ref4.touches;
      var touch = touches.item(0);

      if (!touch) {
        return;
      }

      _this.initialTouchX = touch.clientX;
      _this.initialTouchY = touch.clientY;
      _this.userIsDragging = false;
    };

    _this.onTouchMove = function (_ref5) {
      var touches = _ref5.touches;
      var touch = touches.item(0);

      if (!touch) {
        return;
      }

      var deltaX = Math.abs(touch.clientX - _this.initialTouchX);
      var deltaY = Math.abs(touch.clientY - _this.initialTouchY);
      var moveThreshold = 5;
      _this.userIsDragging = deltaX > moveThreshold || deltaY > moveThreshold;
    };

    _this.onTouchEnd = function (event) {
      if (_this.userIsDragging) return; // close the menu if the user taps outside
      // we're checking on event.target here instead of event.currentTarget, because we want to assert information
      // on events on child elements, not the document (which we've attached this handler to).

      if (_this.controlRef && !_this.controlRef.contains(event.target) && _this.menuListRef && !_this.menuListRef.contains(event.target)) {
        _this.blurInput();
      } // reset move vars


      _this.initialTouchX = 0;
      _this.initialTouchY = 0;
    };

    _this.onControlTouchEnd = function (event) {
      if (_this.userIsDragging) return;

      _this.onControlMouseDown(event);
    };

    _this.onClearIndicatorTouchEnd = function (event) {
      if (_this.userIsDragging) return;

      _this.onClearIndicatorMouseDown(event);
    };

    _this.onDropdownIndicatorTouchEnd = function (event) {
      if (_this.userIsDragging) return;

      _this.onDropdownIndicatorMouseDown(event);
    };

    _this.handleInputChange = function (event) {
      var inputValue = event.currentTarget.value;
      _this.inputIsHiddenAfterUpdate = false;

      _this.onInputChange(inputValue, {
        action: 'input-change'
      });

      _this.onMenuOpen();
    };

    _this.onInputFocus = function (event) {
      var _this$props5 = _this.props,
          isSearchable = _this$props5.isSearchable,
          isMulti = _this$props5.isMulti;

      if (_this.props.onFocus) {
        _this.props.onFocus(event);
      }

      _this.inputIsHiddenAfterUpdate = false;

      _this.announceAriaLiveContext({
        event: 'input',
        context: {
          isSearchable: isSearchable,
          isMulti: isMulti
        }
      });

      _this.setState({
        isFocused: true
      });

      if (_this.openAfterFocus || _this.props.openMenuOnFocus) {
        _this.openMenu('first');
      }

      _this.openAfterFocus = false;
    };

    _this.onInputBlur = function (event) {
      if (_this.menuListRef && _this.menuListRef.contains(document.activeElement)) {
        _this.inputRef.focus();

        return;
      }

      if (_this.props.onBlur) {
        _this.props.onBlur(event);
      }

      _this.onInputChange('', {
        action: 'input-blur'
      });

      _this.onMenuClose();

      _this.setState({
        focusedValue: null,
        isFocused: false
      });
    };

    _this.onOptionHover = function (focusedOption) {
      if (_this.blockOptionHover || _this.state.focusedOption === focusedOption) {
        return;
      }

      _this.setState({
        focusedOption: focusedOption
      });
    };

    _this.shouldHideSelectedOptions = function () {
      var _this$props6 = _this.props,
          hideSelectedOptions = _this$props6.hideSelectedOptions,
          isMulti = _this$props6.isMulti;
      if (hideSelectedOptions === undefined) return isMulti;
      return hideSelectedOptions;
    };

    _this.onKeyDown = function (event) {
      var _this$props7 = _this.props,
          isMulti = _this$props7.isMulti,
          backspaceRemovesValue = _this$props7.backspaceRemovesValue,
          escapeClearsValue = _this$props7.escapeClearsValue,
          inputValue = _this$props7.inputValue,
          isClearable = _this$props7.isClearable,
          isDisabled = _this$props7.isDisabled,
          menuIsOpen = _this$props7.menuIsOpen,
          onKeyDown = _this$props7.onKeyDown,
          tabSelectsValue = _this$props7.tabSelectsValue,
          openMenuOnFocus = _this$props7.openMenuOnFocus;
      var _this$state2 = _this.state,
          focusedOption = _this$state2.focusedOption,
          focusedValue = _this$state2.focusedValue,
          selectValue = _this$state2.selectValue;
      if (isDisabled) return;

      if (typeof onKeyDown === 'function') {
        onKeyDown(event);

        if (event.defaultPrevented) {
          return;
        }
      } // Block option hover events when the user has just pressed a key


      _this.blockOptionHover = true;

      switch (event.key) {
        case 'ArrowLeft':
          if (!isMulti || inputValue) return;

          _this.focusValue('previous');

          break;

        case 'ArrowRight':
          if (!isMulti || inputValue) return;

          _this.focusValue('next');

          break;

        case 'Delete':
        case 'Backspace':
          if (inputValue) return;

          if (focusedValue) {
            _this.removeValue(focusedValue);
          } else {
            if (!backspaceRemovesValue) return;

            if (isMulti) {
              _this.popValue();
            } else if (isClearable) {
              _this.clearValue();
            }
          }

          break;

        case 'Tab':
          if (_this.isComposing) return;

          if (event.shiftKey || !menuIsOpen || !tabSelectsValue || !focusedOption || // don't capture the event if the menu opens on focus and the focused
          // option is already selected; it breaks the flow of navigation
          openMenuOnFocus && _this.isOptionSelected(focusedOption, selectValue)) {
            return;
          }

          _this.selectOption(focusedOption);

          break;

        case 'Enter':
          if (event.keyCode === 229) {
            // ignore the keydown event from an Input Method Editor(IME)
            // ref. https://www.w3.org/TR/uievents/#determine-keydown-keyup-keyCode
            break;
          }

          if (menuIsOpen) {
            if (!focusedOption) return;
            if (_this.isComposing) return;

            _this.selectOption(focusedOption);

            break;
          }

          return;

        case 'Escape':
          if (menuIsOpen) {
            _this.inputIsHiddenAfterUpdate = false;

            _this.onInputChange('', {
              action: 'menu-close'
            });

            _this.onMenuClose();
          } else if (isClearable && escapeClearsValue) {
            _this.clearValue();
          }

          break;

        case ' ':
          // space
          if (inputValue) {
            return;
          }

          if (!menuIsOpen) {
            _this.openMenu('first');

            break;
          }

          if (!focusedOption) return;

          _this.selectOption(focusedOption);

          break;

        case 'ArrowUp':
          if (menuIsOpen) {
            _this.focusOption('up');
          } else {
            _this.openMenu('last');
          }

          break;

        case 'ArrowDown':
          if (menuIsOpen) {
            _this.focusOption('down');
          } else {
            _this.openMenu('first');
          }

          break;

        case 'PageUp':
          if (!menuIsOpen) return;

          _this.focusOption('pageup');

          break;

        case 'PageDown':
          if (!menuIsOpen) return;

          _this.focusOption('pagedown');

          break;

        case 'Home':
          if (!menuIsOpen) return;

          _this.focusOption('first');

          break;

        case 'End':
          if (!menuIsOpen) return;

          _this.focusOption('last');

          break;

        default:
          return;
      }

      event.preventDefault();
    };

    _this.buildMenuOptions = function (props, selectValue) {
      var _props$inputValue = props.inputValue,
          inputValue = _props$inputValue === void 0 ? '' : _props$inputValue,
          options = props.options;

      var toOption = function toOption(option, id) {
        var isDisabled = _this.isOptionDisabled(option, selectValue);

        var isSelected = _this.isOptionSelected(option, selectValue);

        var label = _this.getOptionLabel(option);

        var value = _this.getOptionValue(option);

        if (_this.shouldHideSelectedOptions() && isSelected || !_this.filterOption({
          label: label,
          value: value,
          data: option
        }, inputValue)) {
          return;
        }

        var onHover = isDisabled ? undefined : function () {
          return _this.onOptionHover(option);
        };
        var onSelect = isDisabled ? undefined : function () {
          return _this.selectOption(option);
        };
        var optionId = _this.getElementId('option') + "-" + id;
        return {
          innerProps: {
            id: optionId,
            onClick: onSelect,
            onMouseMove: onHover,
            onMouseOver: onHover,
            tabIndex: -1
          },
          data: option,
          isDisabled: isDisabled,
          isSelected: isSelected,
          key: optionId,
          label: label,
          type: 'option',
          value: value
        };
      };

      return options.reduce(function (acc, item, itemIndex) {
        if (item.options) {
          // TODO needs a tidier implementation
          if (!_this.hasGroups) _this.hasGroups = true;
          var items = item.options;
          var children = items.map(function (child, i) {
            var option = toOption(child, itemIndex + "-" + i);
            if (option) acc.focusable.push(child);
            return option;
          }).filter(Boolean);

          if (children.length) {
            var groupId = _this.getElementId('group') + "-" + itemIndex;
            acc.render.push({
              type: 'group',
              key: groupId,
              data: item,
              options: children
            });
          }
        } else {
          var option = toOption(item, "" + itemIndex);

          if (option) {
            acc.render.push(option);
            acc.focusable.push(item);
          }
        }

        return acc;
      }, {
        render: [],
        focusable: []
      });
    };

    var _value = _props.value;
    _this.cacheComponents = Object(memoize_one__WEBPACK_IMPORTED_MODULE_1__["default"])(_this.cacheComponents, _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["x"]).bind(_assertThisInitialized(_assertThisInitialized(_this)));

    _this.cacheComponents(_props.components);

    _this.instancePrefix = 'react-select-' + (_this.props.instanceId || ++instanceId);

    var _selectValue = Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["e"])(_value);

    _this.buildMenuOptions = Object(memoize_one__WEBPACK_IMPORTED_MODULE_1__["default"])(_this.buildMenuOptions, function (newArgs, lastArgs) {
      var _ref6 = newArgs,
          newProps = _ref6[0],
          newSelectValue = _ref6[1];
      var _ref7 = lastArgs,
          lastProps = _ref7[0],
          lastSelectValue = _ref7[1];
      return Object(_index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["x"])(newSelectValue, lastSelectValue) && Object(_index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["x"])(newProps.inputValue, lastProps.inputValue) && Object(_index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["x"])(newProps.options, lastProps.options);
    }).bind(_assertThisInitialized(_assertThisInitialized(_this)));

    var _menuOptions = _props.menuIsOpen ? _this.buildMenuOptions(_props, _selectValue) : {
      render: [],
      focusable: []
    };

    _this.state.menuOptions = _menuOptions;
    _this.state.selectValue = _selectValue;
    return _this;
  }

  var _proto = Select.prototype;

  _proto.componentDidMount = function componentDidMount() {
    this.startListeningComposition();
    this.startListeningToTouch();

    if (this.props.closeMenuOnScroll && document && document.addEventListener) {
      // Listen to all scroll events, and filter them out inside of 'onScroll'
      document.addEventListener('scroll', this.onScroll, true);
    }

    if (this.props.autoFocus) {
      this.focusInput();
    }
  };

  _proto.UNSAFE_componentWillReceiveProps = function UNSAFE_componentWillReceiveProps(nextProps) {
    var _this$props8 = this.props,
        options = _this$props8.options,
        value = _this$props8.value,
        menuIsOpen = _this$props8.menuIsOpen,
        inputValue = _this$props8.inputValue; // re-cache custom components

    this.cacheComponents(nextProps.components); // rebuild the menu options

    if (nextProps.value !== value || nextProps.options !== options || nextProps.menuIsOpen !== menuIsOpen || nextProps.inputValue !== inputValue) {
      var selectValue = Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["e"])(nextProps.value);
      var menuOptions = nextProps.menuIsOpen ? this.buildMenuOptions(nextProps, selectValue) : {
        render: [],
        focusable: []
      };
      var focusedValue = this.getNextFocusedValue(selectValue);
      var focusedOption = this.getNextFocusedOption(menuOptions.focusable);
      this.setState({
        menuOptions: menuOptions,
        selectValue: selectValue,
        focusedOption: focusedOption,
        focusedValue: focusedValue
      });
    } // some updates should toggle the state of the input visibility


    if (this.inputIsHiddenAfterUpdate != null) {
      this.setState({
        inputIsHidden: this.inputIsHiddenAfterUpdate
      });
      delete this.inputIsHiddenAfterUpdate;
    }
  };

  _proto.componentDidUpdate = function componentDidUpdate(prevProps) {
    var _this$props9 = this.props,
        isDisabled = _this$props9.isDisabled,
        menuIsOpen = _this$props9.menuIsOpen;
    var isFocused = this.state.isFocused;

    if ( // ensure focus is restored correctly when the control becomes enabled
    isFocused && !isDisabled && prevProps.isDisabled || // ensure focus is on the Input when the menu opens
    isFocused && menuIsOpen && !prevProps.menuIsOpen) {
      this.focusInput();
    } // scroll the focused option into view if necessary


    if (this.menuListRef && this.focusedOptionRef && this.scrollToFocusedOptionOnUpdate) {
      Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["f"])(this.menuListRef, this.focusedOptionRef);
      this.scrollToFocusedOptionOnUpdate = false;
    }
  };

  _proto.componentWillUnmount = function componentWillUnmount() {
    this.stopListeningComposition();
    this.stopListeningToTouch();
    document.removeEventListener('scroll', this.onScroll, true);
  };

  // ==============================
  // Consumer Handlers
  // ==============================
  _proto.onMenuOpen = function onMenuOpen() {
    this.props.onMenuOpen();
  };

  _proto.onMenuClose = function onMenuClose() {
    var _this$props10 = this.props,
        isSearchable = _this$props10.isSearchable,
        isMulti = _this$props10.isMulti;
    this.announceAriaLiveContext({
      event: 'input',
      context: {
        isSearchable: isSearchable,
        isMulti: isMulti
      }
    });
    this.onInputChange('', {
      action: 'menu-close'
    });
    this.props.onMenuClose();
  };

  _proto.onInputChange = function onInputChange(newValue, actionMeta) {
    this.props.onInputChange(newValue, actionMeta);
  } // ==============================
  // Methods
  // ==============================
  ;

  _proto.focusInput = function focusInput() {
    if (!this.inputRef) return;
    this.inputRef.focus();
  };

  _proto.blurInput = function blurInput() {
    if (!this.inputRef) return;
    this.inputRef.blur();
  } // aliased for consumers
  ;

  _proto.openMenu = function openMenu(focusOption) {
    var _this2 = this;

    var _this$state3 = this.state,
        selectValue = _this$state3.selectValue,
        isFocused = _this$state3.isFocused;
    var menuOptions = this.buildMenuOptions(this.props, selectValue);
    var isMulti = this.props.isMulti;
    var openAtIndex = focusOption === 'first' ? 0 : menuOptions.focusable.length - 1;

    if (!isMulti) {
      var selectedIndex = menuOptions.focusable.indexOf(selectValue[0]);

      if (selectedIndex > -1) {
        openAtIndex = selectedIndex;
      }
    } // only scroll if the menu isn't already open


    this.scrollToFocusedOptionOnUpdate = !(isFocused && this.menuListRef);
    this.inputIsHiddenAfterUpdate = false;
    this.setState({
      menuOptions: menuOptions,
      focusedValue: null,
      focusedOption: menuOptions.focusable[openAtIndex]
    }, function () {
      _this2.onMenuOpen();

      _this2.announceAriaLiveContext({
        event: 'menu'
      });
    });
  };

  _proto.focusValue = function focusValue(direction) {
    var _this$props11 = this.props,
        isMulti = _this$props11.isMulti,
        isSearchable = _this$props11.isSearchable;
    var _this$state4 = this.state,
        selectValue = _this$state4.selectValue,
        focusedValue = _this$state4.focusedValue; // Only multiselects support value focusing

    if (!isMulti) return;
    this.setState({
      focusedOption: null
    });
    var focusedIndex = selectValue.indexOf(focusedValue);

    if (!focusedValue) {
      focusedIndex = -1;
      this.announceAriaLiveContext({
        event: 'value'
      });
    }

    var lastIndex = selectValue.length - 1;
    var nextFocus = -1;
    if (!selectValue.length) return;

    switch (direction) {
      case 'previous':
        if (focusedIndex === 0) {
          // don't cycle from the start to the end
          nextFocus = 0;
        } else if (focusedIndex === -1) {
          // if nothing is focused, focus the last value first
          nextFocus = lastIndex;
        } else {
          nextFocus = focusedIndex - 1;
        }

        break;

      case 'next':
        if (focusedIndex > -1 && focusedIndex < lastIndex) {
          nextFocus = focusedIndex + 1;
        }

        break;
    }

    if (nextFocus === -1) {
      this.announceAriaLiveContext({
        event: 'input',
        context: {
          isSearchable: isSearchable,
          isMulti: isMulti
        }
      });
    }

    this.setState({
      inputIsHidden: nextFocus !== -1,
      focusedValue: selectValue[nextFocus]
    });
  };

  _proto.focusOption = function focusOption(direction) {
    if (direction === void 0) {
      direction = 'first';
    }

    var pageSize = this.props.pageSize;
    var _this$state5 = this.state,
        focusedOption = _this$state5.focusedOption,
        menuOptions = _this$state5.menuOptions;
    var options = menuOptions.focusable;
    if (!options.length) return;
    var nextFocus = 0; // handles 'first'

    var focusedIndex = options.indexOf(focusedOption);

    if (!focusedOption) {
      focusedIndex = -1;
      this.announceAriaLiveContext({
        event: 'menu'
      });
    }

    if (direction === 'up') {
      nextFocus = focusedIndex > 0 ? focusedIndex - 1 : options.length - 1;
    } else if (direction === 'down') {
      nextFocus = (focusedIndex + 1) % options.length;
    } else if (direction === 'pageup') {
      nextFocus = focusedIndex - pageSize;
      if (nextFocus < 0) nextFocus = 0;
    } else if (direction === 'pagedown') {
      nextFocus = focusedIndex + pageSize;
      if (nextFocus > options.length - 1) nextFocus = options.length - 1;
    } else if (direction === 'last') {
      nextFocus = options.length - 1;
    }

    this.scrollToFocusedOptionOnUpdate = true;
    this.setState({
      focusedOption: options[nextFocus],
      focusedValue: null
    });
    this.announceAriaLiveContext({
      event: 'menu',
      context: {
        isDisabled: isOptionDisabled(options[nextFocus])
      }
    });
  };

  // ==============================
  // Getters
  // ==============================
  _proto.getTheme = function getTheme() {
    // Use the default theme if there are no customizations.
    if (!this.props.theme) {
      return defaultTheme;
    } // If the theme prop is a function, assume the function
    // knows how to merge the passed-in default theme with
    // its own modifications.


    if (typeof this.props.theme === 'function') {
      return this.props.theme(defaultTheme);
    } // Otherwise, if a plain theme object was passed in,
    // overlay it with the default theme.


    return _extends$4({}, defaultTheme, this.props.theme);
  };

  _proto.getCommonProps = function getCommonProps() {
    var clearValue = this.clearValue,
        getStyles = this.getStyles,
        setValue = this.setValue,
        selectOption = this.selectOption,
        props = this.props;
    var classNamePrefix = props.classNamePrefix,
        isMulti = props.isMulti,
        isRtl = props.isRtl,
        options = props.options;
    var selectValue = this.state.selectValue;
    var hasValue = this.hasValue();

    var getValue = function getValue() {
      return selectValue;
    };

    var cx = _utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["h"].bind(null, classNamePrefix);
    return {
      cx: cx,
      clearValue: clearValue,
      getStyles: getStyles,
      getValue: getValue,
      hasValue: hasValue,
      isMulti: isMulti,
      isRtl: isRtl,
      options: options,
      selectOption: selectOption,
      setValue: setValue,
      selectProps: props,
      theme: this.getTheme()
    };
  };

  _proto.getNextFocusedValue = function getNextFocusedValue(nextSelectValue) {
    if (this.clearFocusValueOnUpdate) {
      this.clearFocusValueOnUpdate = false;
      return null;
    }

    var _this$state6 = this.state,
        focusedValue = _this$state6.focusedValue,
        lastSelectValue = _this$state6.selectValue;
    var lastFocusedIndex = lastSelectValue.indexOf(focusedValue);

    if (lastFocusedIndex > -1) {
      var nextFocusedIndex = nextSelectValue.indexOf(focusedValue);

      if (nextFocusedIndex > -1) {
        // the focused value is still in the selectValue, return it
        return focusedValue;
      } else if (lastFocusedIndex < nextSelectValue.length) {
        // the focusedValue is not present in the next selectValue array by
        // reference, so return the new value at the same index
        return nextSelectValue[lastFocusedIndex];
      }
    }

    return null;
  };

  _proto.getNextFocusedOption = function getNextFocusedOption(options) {
    var lastFocusedOption = this.state.focusedOption;
    return lastFocusedOption && options.indexOf(lastFocusedOption) > -1 ? lastFocusedOption : options[0];
  };

  _proto.hasValue = function hasValue() {
    var selectValue = this.state.selectValue;
    return selectValue.length > 0;
  };

  _proto.hasOptions = function hasOptions() {
    return !!this.state.menuOptions.render.length;
  };

  _proto.countOptions = function countOptions() {
    return this.state.menuOptions.focusable.length;
  };

  _proto.isClearable = function isClearable() {
    var _this$props12 = this.props,
        isClearable = _this$props12.isClearable,
        isMulti = _this$props12.isMulti; // single select, by default, IS NOT clearable
    // multi select, by default, IS clearable

    if (isClearable === undefined) return isMulti;
    return isClearable;
  };

  _proto.isOptionDisabled = function isOptionDisabled(option, selectValue) {
    return typeof this.props.isOptionDisabled === 'function' ? this.props.isOptionDisabled(option, selectValue) : false;
  };

  _proto.isOptionSelected = function isOptionSelected(option, selectValue) {
    var _this3 = this;

    if (selectValue.indexOf(option) > -1) return true;

    if (typeof this.props.isOptionSelected === 'function') {
      return this.props.isOptionSelected(option, selectValue);
    }

    var candidate = this.getOptionValue(option);
    return selectValue.some(function (i) {
      return _this3.getOptionValue(i) === candidate;
    });
  };

  _proto.filterOption = function filterOption(option, inputValue) {
    return this.props.filterOption ? this.props.filterOption(option, inputValue) : true;
  };

  _proto.formatOptionLabel = function formatOptionLabel(data, context) {
    if (typeof this.props.formatOptionLabel === 'function') {
      var inputValue = this.props.inputValue;
      var selectValue = this.state.selectValue;
      return this.props.formatOptionLabel(data, {
        context: context,
        inputValue: inputValue,
        selectValue: selectValue
      });
    } else {
      return this.getOptionLabel(data);
    }
  };

  _proto.formatGroupLabel = function formatGroupLabel(data) {
    return this.props.formatGroupLabel(data);
  } // ==============================
  // Mouse Handlers
  // ==============================
  ;

  // ==============================
  // Composition Handlers
  // ==============================
  _proto.startListeningComposition = function startListeningComposition() {
    if (document && document.addEventListener) {
      document.addEventListener('compositionstart', this.onCompositionStart, false);
      document.addEventListener('compositionend', this.onCompositionEnd, false);
    }
  };

  _proto.stopListeningComposition = function stopListeningComposition() {
    if (document && document.removeEventListener) {
      document.removeEventListener('compositionstart', this.onCompositionStart);
      document.removeEventListener('compositionend', this.onCompositionEnd);
    }
  };

  // ==============================
  // Touch Handlers
  // ==============================
  _proto.startListeningToTouch = function startListeningToTouch() {
    if (document && document.addEventListener) {
      document.addEventListener('touchstart', this.onTouchStart, false);
      document.addEventListener('touchmove', this.onTouchMove, false);
      document.addEventListener('touchend', this.onTouchEnd, false);
    }
  };

  _proto.stopListeningToTouch = function stopListeningToTouch() {
    if (document && document.removeEventListener) {
      document.removeEventListener('touchstart', this.onTouchStart);
      document.removeEventListener('touchmove', this.onTouchMove);
      document.removeEventListener('touchend', this.onTouchEnd);
    }
  };

  // ==============================
  // Renderers
  // ==============================
  _proto.constructAriaLiveMessage = function constructAriaLiveMessage() {
    var _this$state7 = this.state,
        ariaLiveContext = _this$state7.ariaLiveContext,
        selectValue = _this$state7.selectValue,
        focusedValue = _this$state7.focusedValue,
        focusedOption = _this$state7.focusedOption;
    var _this$props13 = this.props,
        options = _this$props13.options,
        menuIsOpen = _this$props13.menuIsOpen,
        inputValue = _this$props13.inputValue,
        screenReaderStatus = _this$props13.screenReaderStatus; // An aria live message representing the currently focused value in the select.

    var focusedValueMsg = focusedValue ? valueFocusAriaMessage({
      focusedValue: focusedValue,
      getOptionLabel: this.getOptionLabel,
      selectValue: selectValue
    }) : ''; // An aria live message representing the currently focused option in the select.

    var focusedOptionMsg = focusedOption && menuIsOpen ? optionFocusAriaMessage({
      focusedOption: focusedOption,
      getOptionLabel: this.getOptionLabel,
      options: options
    }) : ''; // An aria live message representing the set of focusable results and current searchterm/inputvalue.

    var resultsMsg = resultsAriaMessage({
      inputValue: inputValue,
      screenReaderMessage: screenReaderStatus({
        count: this.countOptions()
      })
    });
    return focusedValueMsg + " " + focusedOptionMsg + " " + resultsMsg + " " + ariaLiveContext;
  };

  _proto.renderInput = function renderInput() {
    var _this$props14 = this.props,
        isDisabled = _this$props14.isDisabled,
        isSearchable = _this$props14.isSearchable,
        inputId = _this$props14.inputId,
        inputValue = _this$props14.inputValue,
        tabIndex = _this$props14.tabIndex;
    var Input = this.components.Input;
    var inputIsHidden = this.state.inputIsHidden;
    var id = inputId || this.getElementId('input'); // aria attributes makes the JSX "noisy", separated for clarity

    var ariaAttributes = {
      'aria-autocomplete': 'list',
      'aria-label': this.props['aria-label'],
      'aria-labelledby': this.props['aria-labelledby']
    };

    if (!isSearchable) {
      // use a dummy input to maintain focus/blur functionality
      return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(DummyInput, _extends$4({
        id: id,
        innerRef: this.getInputRef,
        onBlur: this.onInputBlur,
        onChange: _utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["n"],
        onFocus: this.onInputFocus,
        readOnly: true,
        disabled: isDisabled,
        tabIndex: tabIndex,
        value: ""
      }, ariaAttributes));
    }

    var _this$commonProps = this.commonProps,
        cx = _this$commonProps.cx,
        theme = _this$commonProps.theme,
        selectProps = _this$commonProps.selectProps;
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(Input, _extends$4({
      autoCapitalize: "none",
      autoComplete: "off",
      autoCorrect: "off",
      cx: cx,
      getStyles: this.getStyles,
      id: id,
      innerRef: this.getInputRef,
      isDisabled: isDisabled,
      isHidden: inputIsHidden,
      onBlur: this.onInputBlur,
      onChange: this.handleInputChange,
      onFocus: this.onInputFocus,
      selectProps: selectProps,
      spellCheck: "false",
      tabIndex: tabIndex,
      theme: theme,
      type: "text",
      value: inputValue
    }, ariaAttributes));
  };

  _proto.renderPlaceholderOrValue = function renderPlaceholderOrValue() {
    var _this4 = this;

    var _this$components = this.components,
        MultiValue = _this$components.MultiValue,
        MultiValueContainer = _this$components.MultiValueContainer,
        MultiValueLabel = _this$components.MultiValueLabel,
        MultiValueRemove = _this$components.MultiValueRemove,
        SingleValue = _this$components.SingleValue,
        Placeholder = _this$components.Placeholder;
    var commonProps = this.commonProps;
    var _this$props15 = this.props,
        controlShouldRenderValue = _this$props15.controlShouldRenderValue,
        isDisabled = _this$props15.isDisabled,
        isMulti = _this$props15.isMulti,
        inputValue = _this$props15.inputValue,
        placeholder = _this$props15.placeholder;
    var _this$state8 = this.state,
        selectValue = _this$state8.selectValue,
        focusedValue = _this$state8.focusedValue,
        isFocused = _this$state8.isFocused;

    if (!this.hasValue() || !controlShouldRenderValue) {
      return inputValue ? null : react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(Placeholder, _extends$4({}, commonProps, {
        key: "placeholder",
        isDisabled: isDisabled,
        isFocused: isFocused
      }), placeholder);
    }

    if (isMulti) {
      var selectValues = selectValue.map(function (opt, index) {
        var isOptionFocused = opt === focusedValue;
        return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(MultiValue, _extends$4({}, commonProps, {
          components: {
            Container: MultiValueContainer,
            Label: MultiValueLabel,
            Remove: MultiValueRemove
          },
          isFocused: isOptionFocused,
          isDisabled: isDisabled,
          key: _this4.getOptionValue(opt),
          index: index,
          removeProps: {
            onClick: function onClick() {
              return _this4.removeValue(opt);
            },
            onTouchEnd: function onTouchEnd() {
              return _this4.removeValue(opt);
            },
            onMouseDown: function onMouseDown(e) {
              e.preventDefault();
              e.stopPropagation();
            }
          },
          data: opt
        }), _this4.formatOptionLabel(opt, 'value'));
      });
      return selectValues;
    }

    if (inputValue) {
      return null;
    }

    var singleValue = selectValue[0];
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(SingleValue, _extends$4({}, commonProps, {
      data: singleValue,
      isDisabled: isDisabled
    }), this.formatOptionLabel(singleValue, 'value'));
  };

  _proto.renderClearIndicator = function renderClearIndicator() {
    var ClearIndicator = this.components.ClearIndicator;
    var commonProps = this.commonProps;
    var _this$props16 = this.props,
        isDisabled = _this$props16.isDisabled,
        isLoading = _this$props16.isLoading;
    var isFocused = this.state.isFocused;

    if (!this.isClearable() || !ClearIndicator || isDisabled || !this.hasValue() || isLoading) {
      return null;
    }

    var innerProps = {
      onMouseDown: this.onClearIndicatorMouseDown,
      onTouchEnd: this.onClearIndicatorTouchEnd,
      'aria-hidden': 'true'
    };
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(ClearIndicator, _extends$4({}, commonProps, {
      innerProps: innerProps,
      isFocused: isFocused
    }));
  };

  _proto.renderLoadingIndicator = function renderLoadingIndicator() {
    var LoadingIndicator = this.components.LoadingIndicator;
    var commonProps = this.commonProps;
    var _this$props17 = this.props,
        isDisabled = _this$props17.isDisabled,
        isLoading = _this$props17.isLoading;
    var isFocused = this.state.isFocused;
    if (!LoadingIndicator || !isLoading) return null;
    var innerProps = {
      'aria-hidden': 'true'
    };
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(LoadingIndicator, _extends$4({}, commonProps, {
      innerProps: innerProps,
      isDisabled: isDisabled,
      isFocused: isFocused
    }));
  };

  _proto.renderIndicatorSeparator = function renderIndicatorSeparator() {
    var _this$components2 = this.components,
        DropdownIndicator = _this$components2.DropdownIndicator,
        IndicatorSeparator = _this$components2.IndicatorSeparator; // separator doesn't make sense without the dropdown indicator

    if (!DropdownIndicator || !IndicatorSeparator) return null;
    var commonProps = this.commonProps;
    var isDisabled = this.props.isDisabled;
    var isFocused = this.state.isFocused;
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(IndicatorSeparator, _extends$4({}, commonProps, {
      isDisabled: isDisabled,
      isFocused: isFocused
    }));
  };

  _proto.renderDropdownIndicator = function renderDropdownIndicator() {
    var DropdownIndicator = this.components.DropdownIndicator;
    if (!DropdownIndicator) return null;
    var commonProps = this.commonProps;
    var isDisabled = this.props.isDisabled;
    var isFocused = this.state.isFocused;
    var innerProps = {
      onMouseDown: this.onDropdownIndicatorMouseDown,
      onTouchEnd: this.onDropdownIndicatorTouchEnd,
      'aria-hidden': 'true'
    };
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(DropdownIndicator, _extends$4({}, commonProps, {
      innerProps: innerProps,
      isDisabled: isDisabled,
      isFocused: isFocused
    }));
  };

  _proto.renderMenu = function renderMenu() {
    var _this5 = this;

    var _this$components3 = this.components,
        Group = _this$components3.Group,
        GroupHeading = _this$components3.GroupHeading,
        Menu = _this$components3.Menu,
        MenuList = _this$components3.MenuList,
        MenuPortal = _this$components3.MenuPortal,
        LoadingMessage = _this$components3.LoadingMessage,
        NoOptionsMessage = _this$components3.NoOptionsMessage,
        Option = _this$components3.Option;
    var commonProps = this.commonProps;
    var _this$state9 = this.state,
        focusedOption = _this$state9.focusedOption,
        menuOptions = _this$state9.menuOptions;
    var _this$props18 = this.props,
        captureMenuScroll = _this$props18.captureMenuScroll,
        inputValue = _this$props18.inputValue,
        isLoading = _this$props18.isLoading,
        loadingMessage = _this$props18.loadingMessage,
        minMenuHeight = _this$props18.minMenuHeight,
        maxMenuHeight = _this$props18.maxMenuHeight,
        menuIsOpen = _this$props18.menuIsOpen,
        menuPlacement = _this$props18.menuPlacement,
        menuPosition = _this$props18.menuPosition,
        menuPortalTarget = _this$props18.menuPortalTarget,
        menuShouldBlockScroll = _this$props18.menuShouldBlockScroll,
        menuShouldScrollIntoView = _this$props18.menuShouldScrollIntoView,
        noOptionsMessage = _this$props18.noOptionsMessage,
        onMenuScrollToTop = _this$props18.onMenuScrollToTop,
        onMenuScrollToBottom = _this$props18.onMenuScrollToBottom;
    if (!menuIsOpen) return null; // TODO: Internal Option Type here

    var render = function render(props) {
      // for performance, the menu options in state aren't changed when the
      // focused option changes so we calculate additional props based on that
      var isFocused = focusedOption === props.data;
      props.innerRef = isFocused ? _this5.getFocusedOptionRef : undefined;
      return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(Option, _extends$4({}, commonProps, props, {
        isFocused: isFocused
      }), _this5.formatOptionLabel(props.data, 'menu'));
    };

    var menuUI;

    if (this.hasOptions()) {
      menuUI = menuOptions.render.map(function (item) {
        if (item.type === 'group') {
          var type = item.type,
              group = _objectWithoutPropertiesLoose$2(item, ["type"]);

          var headingId = item.key + "-heading";
          return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(Group, _extends$4({}, commonProps, group, {
            Heading: GroupHeading,
            headingProps: {
              id: headingId
            },
            label: _this5.formatGroupLabel(item.data)
          }), item.options.map(function (option) {
            return render(option);
          }));
        } else if (item.type === 'option') {
          return render(item);
        }
      });
    } else if (isLoading) {
      var message = loadingMessage({
        inputValue: inputValue
      });
      if (message === null) return null;
      menuUI = react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(LoadingMessage, commonProps, message);
    } else {
      var _message = noOptionsMessage({
        inputValue: inputValue
      });

      if (_message === null) return null;
      menuUI = react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(NoOptionsMessage, commonProps, _message);
    }

    var menuPlacementProps = {
      minMenuHeight: minMenuHeight,
      maxMenuHeight: maxMenuHeight,
      menuPlacement: menuPlacement,
      menuPosition: menuPosition,
      menuShouldScrollIntoView: menuShouldScrollIntoView
    };
    var menuElement = react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__["M"], _extends$4({}, commonProps, menuPlacementProps), function (_ref8) {
      var ref = _ref8.ref,
          _ref8$placerProps = _ref8.placerProps,
          placement = _ref8$placerProps.placement,
          maxHeight = _ref8$placerProps.maxHeight;
      return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(Menu, _extends$4({}, commonProps, menuPlacementProps, {
        innerRef: ref,
        innerProps: {
          onMouseDown: _this5.onMenuMouseDown,
          onMouseMove: _this5.onMenuMouseMove
        },
        isLoading: isLoading,
        placement: placement
      }), react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(ScrollCaptorSwitch, {
        isEnabled: captureMenuScroll,
        onTopArrive: onMenuScrollToTop,
        onBottomArrive: onMenuScrollToBottom
      }, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(ScrollBlock, {
        isEnabled: menuShouldBlockScroll
      }, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(MenuList, _extends$4({}, commonProps, {
        innerRef: _this5.getMenuListRef,
        isLoading: isLoading,
        maxHeight: maxHeight
      }), menuUI))));
    }); // positioning behaviour is almost identical for portalled and fixed,
    // so we use the same component. the actual portalling logic is forked
    // within the component based on `menuPosition`

    return menuPortalTarget || menuPosition === 'fixed' ? react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(MenuPortal, _extends$4({}, commonProps, {
      appendTo: menuPortalTarget,
      controlElement: this.controlRef,
      menuPlacement: menuPlacement,
      menuPosition: menuPosition
    }), menuElement) : menuElement;
  };

  _proto.renderFormField = function renderFormField() {
    var _this6 = this;

    var _this$props19 = this.props,
        delimiter = _this$props19.delimiter,
        isDisabled = _this$props19.isDisabled,
        isMulti = _this$props19.isMulti,
        name = _this$props19.name;
    var selectValue = this.state.selectValue;
    if (!name || isDisabled) return;

    if (isMulti) {
      if (delimiter) {
        var value = selectValue.map(function (opt) {
          return _this6.getOptionValue(opt);
        }).join(delimiter);
        return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("input", {
          name: name,
          type: "hidden",
          value: value
        });
      } else {
        var input = selectValue.length > 0 ? selectValue.map(function (opt, i) {
          return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("input", {
            key: "i-" + i,
            name: name,
            type: "hidden",
            value: _this6.getOptionValue(opt)
          });
        }) : react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("input", {
          name: name,
          type: "hidden"
        });
        return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("div", null, input);
      }
    } else {
      var _value2 = selectValue[0] ? this.getOptionValue(selectValue[0]) : '';

      return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("input", {
        name: name,
        type: "hidden",
        value: _value2
      });
    }
  };

  _proto.renderLiveRegion = function renderLiveRegion() {
    if (!this.state.isFocused) return null;
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(A11yText, {
      "aria-live": "polite"
    }, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("p", {
      id: "aria-selection-event"
    }, "\xA0", this.state.ariaLiveSelection), react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("p", {
      id: "aria-context"
    }, "\xA0", this.constructAriaLiveMessage()));
  };

  _proto.render = function render() {
    var _this$components4 = this.components,
        Control = _this$components4.Control,
        IndicatorsContainer = _this$components4.IndicatorsContainer,
        SelectContainer = _this$components4.SelectContainer,
        ValueContainer = _this$components4.ValueContainer;
    var _this$props20 = this.props,
        className = _this$props20.className,
        id = _this$props20.id,
        isDisabled = _this$props20.isDisabled,
        menuIsOpen = _this$props20.menuIsOpen;
    var isFocused = this.state.isFocused;
    var commonProps = this.commonProps = this.getCommonProps();
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(SelectContainer, _extends$4({}, commonProps, {
      className: className,
      innerProps: {
        id: id,
        onKeyDown: this.onKeyDown
      },
      isDisabled: isDisabled,
      isFocused: isFocused
    }), this.renderLiveRegion(), react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(Control, _extends$4({}, commonProps, {
      innerRef: this.getControlRef,
      innerProps: {
        onMouseDown: this.onControlMouseDown,
        onTouchEnd: this.onControlTouchEnd
      },
      isDisabled: isDisabled,
      isFocused: isFocused,
      menuIsOpen: menuIsOpen
    }), react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(ValueContainer, _extends$4({}, commonProps, {
      isDisabled: isDisabled
    }), this.renderPlaceholderOrValue(), this.renderInput()), react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(IndicatorsContainer, _extends$4({}, commonProps, {
      isDisabled: isDisabled
    }), this.renderClearIndicator(), this.renderLoadingIndicator(), this.renderIndicatorSeparator(), this.renderDropdownIndicator())), this.renderMenu(), this.renderFormField());
  };

  return Select;
}(react__WEBPACK_IMPORTED_MODULE_0__["Component"]);

Select.defaultProps = defaultProps;




/***/ }),

/***/ "./node_modules/react-select/dist/index-4322c0ed.browser.esm.js":
/*!**********************************************************************!*\
  !*** ./node_modules/react-select/dist/index-4322c0ed.browser.esm.js ***!
  \**********************************************************************/
/*! exports provided: M, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "M", function() { return MenuPlacer; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return containerCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "b", function() { return css; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "c", function() { return clearIndicatorCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "d", function() { return dropdownIndicatorCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "e", function() { return groupHeadingCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "f", function() { return indicatorSeparatorCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "g", function() { return groupCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "h", function() { return inputCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "i", function() { return indicatorsContainerCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "j", function() { return loadingMessageCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "k", function() { return menuListCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "l", function() { return loadingIndicatorCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "m", function() { return menuCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "n", function() { return menuPortalCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "o", function() { return multiValueCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "p", function() { return multiValueLabelCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "q", function() { return multiValueRemoveCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "r", function() { return noOptionsMessageCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "s", function() { return optionCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "t", function() { return placeholderCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "u", function() { return css$1; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "v", function() { return valueContainerCSS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "w", function() { return defaultComponents; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "x", function() { return exportedEqual; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "y", function() { return components; });
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _emotion_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @emotion/core */ "./node_modules/@emotion/core/dist/core.browser.esm.js");
/* harmony import */ var react_dom__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! react-dom */ "react-dom");
/* harmony import */ var react_dom__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(react_dom__WEBPACK_IMPORTED_MODULE_2__);
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! prop-types */ "./node_modules/prop-types/index.js");
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_3___default = /*#__PURE__*/__webpack_require__.n(prop_types__WEBPACK_IMPORTED_MODULE_3__);
/* harmony import */ var _utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./utils-06b0d5a4.browser.esm.js */ "./node_modules/react-select/dist/utils-06b0d5a4.browser.esm.js");
/* harmony import */ var _emotion_css__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! @emotion/css */ "./node_modules/@emotion/css/dist/css.browser.esm.js");
/* harmony import */ var react_input_autosize__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! react-input-autosize */ "./node_modules/react-input-autosize/lib/AutosizeInput.js");
/* harmony import */ var react_input_autosize__WEBPACK_IMPORTED_MODULE_6___default = /*#__PURE__*/__webpack_require__.n(react_input_autosize__WEBPACK_IMPORTED_MODULE_6__);








function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }
function getMenuPlacement(_ref) {
  var maxHeight = _ref.maxHeight,
      menuEl = _ref.menuEl,
      minHeight = _ref.minHeight,
      placement = _ref.placement,
      shouldScroll = _ref.shouldScroll,
      isFixedPosition = _ref.isFixedPosition,
      theme = _ref.theme;
  var spacing = theme.spacing;
  var scrollParent = Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["a"])(menuEl);
  var defaultState = {
    placement: 'bottom',
    maxHeight: maxHeight
  }; // something went wrong, return default state

  if (!menuEl || !menuEl.offsetParent) return defaultState; // we can't trust `scrollParent.scrollHeight` --> it may increase when
  // the menu is rendered

  var _scrollParent$getBoun = scrollParent.getBoundingClientRect(),
      scrollHeight = _scrollParent$getBoun.height;

  var _menuEl$getBoundingCl = menuEl.getBoundingClientRect(),
      menuBottom = _menuEl$getBoundingCl.bottom,
      menuHeight = _menuEl$getBoundingCl.height,
      menuTop = _menuEl$getBoundingCl.top;

  var _menuEl$offsetParent$ = menuEl.offsetParent.getBoundingClientRect(),
      containerTop = _menuEl$offsetParent$.top;

  var viewHeight = window.innerHeight;
  var scrollTop = Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["b"])(scrollParent);
  var marginBottom = parseInt(getComputedStyle(menuEl).marginBottom, 10);
  var marginTop = parseInt(getComputedStyle(menuEl).marginTop, 10);
  var viewSpaceAbove = containerTop - marginTop;
  var viewSpaceBelow = viewHeight - menuTop;
  var scrollSpaceAbove = viewSpaceAbove + scrollTop;
  var scrollSpaceBelow = scrollHeight - scrollTop - menuTop;
  var scrollDown = menuBottom - viewHeight + scrollTop + marginBottom;
  var scrollUp = scrollTop + menuTop - marginTop;
  var scrollDuration = 160;

  switch (placement) {
    case 'auto':
    case 'bottom':
      // 1: the menu will fit, do nothing
      if (viewSpaceBelow >= menuHeight) {
        return {
          placement: 'bottom',
          maxHeight: maxHeight
        };
      } // 2: the menu will fit, if scrolled


      if (scrollSpaceBelow >= menuHeight && !isFixedPosition) {
        if (shouldScroll) {
          Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["c"])(scrollParent, scrollDown, scrollDuration);
        }

        return {
          placement: 'bottom',
          maxHeight: maxHeight
        };
      } // 3: the menu will fit, if constrained


      if (!isFixedPosition && scrollSpaceBelow >= minHeight || isFixedPosition && viewSpaceBelow >= minHeight) {
        if (shouldScroll) {
          Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["c"])(scrollParent, scrollDown, scrollDuration);
        } // we want to provide as much of the menu as possible to the user,
        // so give them whatever is available below rather than the minHeight.


        var constrainedHeight = isFixedPosition ? viewSpaceBelow - marginBottom : scrollSpaceBelow - marginBottom;
        return {
          placement: 'bottom',
          maxHeight: constrainedHeight
        };
      } // 4. Forked beviour when there isn't enough space below
      // AUTO: flip the menu, render above


      if (placement === 'auto' || isFixedPosition) {
        // may need to be constrained after flipping
        var _constrainedHeight = maxHeight;
        var spaceAbove = isFixedPosition ? viewSpaceAbove : scrollSpaceAbove;

        if (spaceAbove >= minHeight) {
          _constrainedHeight = Math.min(spaceAbove - marginBottom - spacing.controlHeight, maxHeight);
        }

        return {
          placement: 'top',
          maxHeight: _constrainedHeight
        };
      } // BOTTOM: allow browser to increase scrollable area and immediately set scroll


      if (placement === 'bottom') {
        Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["s"])(scrollParent, scrollDown);
        return {
          placement: 'bottom',
          maxHeight: maxHeight
        };
      }

      break;

    case 'top':
      // 1: the menu will fit, do nothing
      if (viewSpaceAbove >= menuHeight) {
        return {
          placement: 'top',
          maxHeight: maxHeight
        };
      } // 2: the menu will fit, if scrolled


      if (scrollSpaceAbove >= menuHeight && !isFixedPosition) {
        if (shouldScroll) {
          Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["c"])(scrollParent, scrollUp, scrollDuration);
        }

        return {
          placement: 'top',
          maxHeight: maxHeight
        };
      } // 3: the menu will fit, if constrained


      if (!isFixedPosition && scrollSpaceAbove >= minHeight || isFixedPosition && viewSpaceAbove >= minHeight) {
        var _constrainedHeight2 = maxHeight; // we want to provide as much of the menu as possible to the user,
        // so give them whatever is available below rather than the minHeight.

        if (!isFixedPosition && scrollSpaceAbove >= minHeight || isFixedPosition && viewSpaceAbove >= minHeight) {
          _constrainedHeight2 = isFixedPosition ? viewSpaceAbove - marginTop : scrollSpaceAbove - marginTop;
        }

        if (shouldScroll) {
          Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["c"])(scrollParent, scrollUp, scrollDuration);
        }

        return {
          placement: 'top',
          maxHeight: _constrainedHeight2
        };
      } // 4. not enough space, the browser WILL NOT increase scrollable area when
      // absolutely positioned element rendered above the viewport (only below).
      // Flip the menu, render below


      return {
        placement: 'bottom',
        maxHeight: maxHeight
      };

    default:
      throw new Error("Invalid placement provided \"" + placement + "\".");
  } // fulfil contract with flow: implicit return value of undefined


  return defaultState;
} // Menu Component
// ------------------------------

function alignToControl(placement) {
  var placementToCSSProp = {
    bottom: 'top',
    top: 'bottom'
  };
  return placement ? placementToCSSProp[placement] : 'bottom';
}

var coercePlacement = function coercePlacement(p) {
  return p === 'auto' ? 'bottom' : p;
};

var menuCSS = function menuCSS(_ref2) {
  var _ref3;

  var placement = _ref2.placement,
      _ref2$theme = _ref2.theme,
      borderRadius = _ref2$theme.borderRadius,
      spacing = _ref2$theme.spacing,
      colors = _ref2$theme.colors;
  return _ref3 = {
    label: 'menu'
  }, _ref3[alignToControl(placement)] = '100%', _ref3.backgroundColor = colors.neutral0, _ref3.borderRadius = borderRadius, _ref3.boxShadow = '0 0 0 1px hsla(0, 0%, 0%, 0.1), 0 4px 11px hsla(0, 0%, 0%, 0.1)', _ref3.marginBottom = spacing.menuGutter, _ref3.marginTop = spacing.menuGutter, _ref3.position = 'absolute', _ref3.width = '100%', _ref3.zIndex = 1, _ref3;
}; // NOTE: internal only

var MenuPlacer =
/*#__PURE__*/
function (_Component) {
  _inheritsLoose(MenuPlacer, _Component);

  function MenuPlacer() {
    var _this;

    for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
      args[_key] = arguments[_key];
    }

    _this = _Component.call.apply(_Component, [this].concat(args)) || this;
    _this.state = {
      maxHeight: _this.props.maxMenuHeight,
      placement: null
    };

    _this.getPlacement = function (ref) {
      var _this$props = _this.props,
          minMenuHeight = _this$props.minMenuHeight,
          maxMenuHeight = _this$props.maxMenuHeight,
          menuPlacement = _this$props.menuPlacement,
          menuPosition = _this$props.menuPosition,
          menuShouldScrollIntoView = _this$props.menuShouldScrollIntoView,
          theme = _this$props.theme;
      var getPortalPlacement = _this.context.getPortalPlacement;
      if (!ref) return; // DO NOT scroll if position is fixed

      var isFixedPosition = menuPosition === 'fixed';
      var shouldScroll = menuShouldScrollIntoView && !isFixedPosition;
      var state = getMenuPlacement({
        maxHeight: maxMenuHeight,
        menuEl: ref,
        minHeight: minMenuHeight,
        placement: menuPlacement,
        shouldScroll: shouldScroll,
        isFixedPosition: isFixedPosition,
        theme: theme
      });
      if (getPortalPlacement) getPortalPlacement(state);

      _this.setState(state);
    };

    _this.getUpdatedProps = function () {
      var menuPlacement = _this.props.menuPlacement;
      var placement = _this.state.placement || coercePlacement(menuPlacement);
      return _extends({}, _this.props, {
        placement: placement,
        maxHeight: _this.state.maxHeight
      });
    };

    return _this;
  }

  var _proto = MenuPlacer.prototype;

  _proto.render = function render() {
    var children = this.props.children;
    return children({
      ref: this.getPlacement,
      placerProps: this.getUpdatedProps()
    });
  };

  return MenuPlacer;
}(react__WEBPACK_IMPORTED_MODULE_0__["Component"]);
MenuPlacer.contextTypes = {
  getPortalPlacement: prop_types__WEBPACK_IMPORTED_MODULE_3___default.a.func
};

var Menu = function Menu(props) {
  var children = props.children,
      className = props.className,
      cx = props.cx,
      getStyles = props.getStyles,
      innerRef = props.innerRef,
      innerProps = props.innerProps;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", _extends({
    css: getStyles('menu', props),
    className: cx({
      menu: true
    }, className)
  }, innerProps, {
    ref: innerRef
  }), children);
};
// Menu List
// ==============================

var menuListCSS = function menuListCSS(_ref4) {
  var maxHeight = _ref4.maxHeight,
      baseUnit = _ref4.theme.spacing.baseUnit;
  return {
    maxHeight: maxHeight,
    overflowY: 'auto',
    paddingBottom: baseUnit,
    paddingTop: baseUnit,
    position: 'relative',
    // required for offset[Height, Top] > keyboard scroll
    WebkitOverflowScrolling: 'touch'
  };
};
var MenuList = function MenuList(props) {
  var children = props.children,
      className = props.className,
      cx = props.cx,
      getStyles = props.getStyles,
      isMulti = props.isMulti,
      innerRef = props.innerRef;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", {
    css: getStyles('menuList', props),
    className: cx({
      'menu-list': true,
      'menu-list--is-multi': isMulti
    }, className),
    ref: innerRef
  }, children);
}; // ==============================
// Menu Notices
// ==============================

var noticeCSS = function noticeCSS(_ref5) {
  var _ref5$theme = _ref5.theme,
      baseUnit = _ref5$theme.spacing.baseUnit,
      colors = _ref5$theme.colors;
  return {
    color: colors.neutral40,
    padding: baseUnit * 2 + "px " + baseUnit * 3 + "px",
    textAlign: 'center'
  };
};

var noOptionsMessageCSS = noticeCSS;
var loadingMessageCSS = noticeCSS;
var NoOptionsMessage = function NoOptionsMessage(props) {
  var children = props.children,
      className = props.className,
      cx = props.cx,
      getStyles = props.getStyles,
      innerProps = props.innerProps;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", _extends({
    css: getStyles('noOptionsMessage', props),
    className: cx({
      'menu-notice': true,
      'menu-notice--no-options': true
    }, className)
  }, innerProps), children);
};
NoOptionsMessage.defaultProps = {
  children: 'No options'
};
var LoadingMessage = function LoadingMessage(props) {
  var children = props.children,
      className = props.className,
      cx = props.cx,
      getStyles = props.getStyles,
      innerProps = props.innerProps;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", _extends({
    css: getStyles('loadingMessage', props),
    className: cx({
      'menu-notice': true,
      'menu-notice--loading': true
    }, className)
  }, innerProps), children);
};
LoadingMessage.defaultProps = {
  children: 'Loading...'
}; // ==============================
// Menu Portal
// ==============================

var menuPortalCSS = function menuPortalCSS(_ref6) {
  var rect = _ref6.rect,
      offset = _ref6.offset,
      position = _ref6.position;
  return {
    left: rect.left,
    position: position,
    top: offset,
    width: rect.width,
    zIndex: 1
  };
};
var MenuPortal =
/*#__PURE__*/
function (_Component2) {
  _inheritsLoose(MenuPortal, _Component2);

  function MenuPortal() {
    var _this2;

    for (var _len2 = arguments.length, args = new Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
      args[_key2] = arguments[_key2];
    }

    _this2 = _Component2.call.apply(_Component2, [this].concat(args)) || this;
    _this2.state = {
      placement: null
    };

    _this2.getPortalPlacement = function (_ref7) {
      var placement = _ref7.placement;
      var initialPlacement = coercePlacement(_this2.props.menuPlacement); // avoid re-renders if the placement has not changed

      if (placement !== initialPlacement) {
        _this2.setState({
          placement: placement
        });
      }
    };

    return _this2;
  }

  var _proto2 = MenuPortal.prototype;

  _proto2.getChildContext = function getChildContext() {
    return {
      getPortalPlacement: this.getPortalPlacement
    };
  } // callback for occassions where the menu must "flip"
  ;

  _proto2.render = function render() {
    var _this$props2 = this.props,
        appendTo = _this$props2.appendTo,
        children = _this$props2.children,
        controlElement = _this$props2.controlElement,
        menuPlacement = _this$props2.menuPlacement,
        position = _this$props2.menuPosition,
        getStyles = _this$props2.getStyles;
    var isFixed = position === 'fixed'; // bail early if required elements aren't present

    if (!appendTo && !isFixed || !controlElement) {
      return null;
    }

    var placement = this.state.placement || coercePlacement(menuPlacement);
    var rect = Object(_utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_4__["g"])(controlElement);
    var scrollDistance = isFixed ? 0 : window.pageYOffset;
    var offset = rect[placement] + scrollDistance;
    var state = {
      offset: offset,
      position: position,
      rect: rect
    }; // same wrapper element whether fixed or portalled

    var menuWrapper = Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", {
      css: getStyles('menuPortal', state)
    }, children);
    return appendTo ? Object(react_dom__WEBPACK_IMPORTED_MODULE_2__["createPortal"])(menuWrapper, appendTo) : menuWrapper;
  };

  return MenuPortal;
}(react__WEBPACK_IMPORTED_MODULE_0__["Component"]);
MenuPortal.childContextTypes = {
  getPortalPlacement: prop_types__WEBPACK_IMPORTED_MODULE_3___default.a.func
};

var isArray = Array.isArray;
var keyList = Object.keys;
var hasProp = Object.prototype.hasOwnProperty;

function equal(a, b) {
  // fast-deep-equal index.js 2.0.1
  if (a === b) return true;

  if (a && b && typeof a == 'object' && typeof b == 'object') {
    var arrA = isArray(a),
        arrB = isArray(b),
        i,
        length,
        key;

    if (arrA && arrB) {
      length = a.length;
      if (length != b.length) return false;

      for (i = length; i-- !== 0;) {
        if (!equal(a[i], b[i])) return false;
      }

      return true;
    }

    if (arrA != arrB) return false;
    var dateA = a instanceof Date,
        dateB = b instanceof Date;
    if (dateA != dateB) return false;
    if (dateA && dateB) return a.getTime() == b.getTime();
    var regexpA = a instanceof RegExp,
        regexpB = b instanceof RegExp;
    if (regexpA != regexpB) return false;
    if (regexpA && regexpB) return a.toString() == b.toString();
    var keys = keyList(a);
    length = keys.length;

    if (length !== keyList(b).length) {
      return false;
    }

    for (i = length; i-- !== 0;) {
      if (!hasProp.call(b, keys[i])) return false;
    } // end fast-deep-equal
    // Custom handling for React


    for (i = length; i-- !== 0;) {
      key = keys[i];

      if (key === '_owner' && a.$$typeof) {
        // React-specific: avoid traversing React elements' _owner.
        //  _owner contains circular references
        // and is not needed when comparing the actual elements (and not their owners)
        // .$$typeof and ._store on just reasonable markers of a react element
        continue;
      } else {
        // all other properties should be traversed as usual
        if (!equal(a[key], b[key])) return false;
      }
    } // fast-deep-equal index.js 2.0.1


    return true;
  }

  return a !== a && b !== b;
} // end fast-deep-equal


function exportedEqual(a, b) {
  try {
    return equal(a, b);
  } catch (error) {
    if (error.message && error.message.match(/stack|recursion/i)) {
      // warn on circular references, don't crash
      // browsers give this different errors name and messages:
      // chrome/safari: "RangeError", "Maximum call stack size exceeded"
      // firefox: "InternalError", too much recursion"
      // edge: "Error", "Out of stack space"
      console.warn('Warning: react-fast-compare does not handle circular references.', error.name, error.message);
      return false;
    } // some other error. we should definitely know about these


    throw error;
  }
}

function _extends$1() { _extends$1 = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends$1.apply(this, arguments); }
var containerCSS = function containerCSS(_ref) {
  var isDisabled = _ref.isDisabled,
      isRtl = _ref.isRtl;
  return {
    label: 'container',
    direction: isRtl ? 'rtl' : null,
    pointerEvents: isDisabled ? 'none' : null,
    // cancel mouse events when disabled
    position: 'relative'
  };
};
var SelectContainer = function SelectContainer(props) {
  var children = props.children,
      className = props.className,
      cx = props.cx,
      getStyles = props.getStyles,
      innerProps = props.innerProps,
      isDisabled = props.isDisabled,
      isRtl = props.isRtl;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", _extends$1({
    css: getStyles('container', props),
    className: cx({
      '--is-disabled': isDisabled,
      '--is-rtl': isRtl
    }, className)
  }, innerProps), children);
}; // ==============================
// Value Container
// ==============================

var valueContainerCSS = function valueContainerCSS(_ref2) {
  var spacing = _ref2.theme.spacing;
  return {
    alignItems: 'center',
    display: 'flex',
    flex: 1,
    flexWrap: 'wrap',
    padding: spacing.baseUnit / 2 + "px " + spacing.baseUnit * 2 + "px",
    WebkitOverflowScrolling: 'touch',
    position: 'relative',
    overflow: 'hidden'
  };
};
var ValueContainer = function ValueContainer(props) {
  var children = props.children,
      className = props.className,
      cx = props.cx,
      isMulti = props.isMulti,
      getStyles = props.getStyles,
      hasValue = props.hasValue;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", {
    css: getStyles('valueContainer', props),
    className: cx({
      'value-container': true,
      'value-container--is-multi': isMulti,
      'value-container--has-value': hasValue
    }, className)
  }, children);
}; // ==============================
// Indicator Container
// ==============================

var indicatorsContainerCSS = function indicatorsContainerCSS() {
  return {
    alignItems: 'center',
    alignSelf: 'stretch',
    display: 'flex',
    flexShrink: 0
  };
};
var IndicatorsContainer = function IndicatorsContainer(props) {
  var children = props.children,
      className = props.className,
      cx = props.cx,
      getStyles = props.getStyles;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", {
    css: getStyles('indicatorsContainer', props),
    className: cx({
      indicators: true
    }, className)
  }, children);
};

function _templateObject() {
  var data = _taggedTemplateLiteralLoose(["\n  0%, 80%, 100% { opacity: 0; }\n  40% { opacity: 1; }\n"]);

  _templateObject = function _templateObject() {
    return data;
  };

  return data;
}

function _taggedTemplateLiteralLoose(strings, raw) { if (!raw) { raw = strings.slice(0); } strings.raw = raw; return strings; }

function _extends$2() { _extends$2 = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends$2.apply(this, arguments); }

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var _ref2 =  false ? undefined : {
  name: "19bqh2r",
  styles: "display:inline-block;fill:currentColor;line-height:1;stroke:currentColor;stroke-width:0;",
  map: "/*# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbImluZGljYXRvcnMuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBa0JJIiwiZmlsZSI6ImluZGljYXRvcnMuanMiLCJzb3VyY2VzQ29udGVudCI6WyIvLyBAZmxvd1xuLyoqIEBqc3gganN4ICovXG5pbXBvcnQgeyB0eXBlIE5vZGUgfSBmcm9tICdyZWFjdCc7XG5pbXBvcnQgeyBqc3gsIGtleWZyYW1lcyB9IGZyb20gJ0BlbW90aW9uL2NvcmUnO1xuXG5pbXBvcnQgdHlwZSB7IENvbW1vblByb3BzLCBUaGVtZSB9IGZyb20gJy4uL3R5cGVzJztcblxuLy8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XG4vLyBEcm9wZG93biAmIENsZWFyIEljb25zXG4vLyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT1cblxuY29uc3QgU3ZnID0gKHsgc2l6ZSwgLi4ucHJvcHMgfTogeyBzaXplOiBudW1iZXIgfSkgPT4gKFxuICA8c3ZnXG4gICAgaGVpZ2h0PXtzaXplfVxuICAgIHdpZHRoPXtzaXplfVxuICAgIHZpZXdCb3g9XCIwIDAgMjAgMjBcIlxuICAgIGFyaWEtaGlkZGVuPVwidHJ1ZVwiXG4gICAgZm9jdXNhYmxlPVwiZmFsc2VcIlxuICAgIGNzcz17e1xuICAgICAgZGlzcGxheTogJ2lubGluZS1ibG9jaycsXG4gICAgICBmaWxsOiAnY3VycmVudENvbG9yJyxcbiAgICAgIGxpbmVIZWlnaHQ6IDEsXG4gICAgICBzdHJva2U6ICdjdXJyZW50Q29sb3InLFxuICAgICAgc3Ryb2tlV2lkdGg6IDAsXG4gICAgfX1cbiAgICB7Li4ucHJvcHN9XG4gIC8+XG4pO1xuXG5leHBvcnQgY29uc3QgQ3Jvc3NJY29uID0gKHByb3BzOiBhbnkpID0+IChcbiAgPFN2ZyBzaXplPXsyMH0gey4uLnByb3BzfT5cbiAgICA8cGF0aCBkPVwiTTE0LjM0OCAxNC44NDljLTAuNDY5IDAuNDY5LTEuMjI5IDAuNDY5LTEuNjk3IDBsLTIuNjUxLTMuMDMwLTIuNjUxIDMuMDI5Yy0wLjQ2OSAwLjQ2OS0xLjIyOSAwLjQ2OS0xLjY5NyAwLTAuNDY5LTAuNDY5LTAuNDY5LTEuMjI5IDAtMS42OTdsMi43NTgtMy4xNS0yLjc1OS0zLjE1MmMtMC40NjktMC40NjktMC40NjktMS4yMjggMC0xLjY5N3MxLjIyOC0wLjQ2OSAxLjY5NyAwbDIuNjUyIDMuMDMxIDIuNjUxLTMuMDMxYzAuNDY5LTAuNDY5IDEuMjI4LTAuNDY5IDEuNjk3IDBzMC40NjkgMS4yMjkgMCAxLjY5N2wtMi43NTggMy4xNTIgMi43NTggMy4xNWMwLjQ2OSAwLjQ2OSAwLjQ2OSAxLjIyOSAwIDEuNjk4elwiIC8+XG4gIDwvU3ZnPlxuKTtcbmV4cG9ydCBjb25zdCBEb3duQ2hldnJvbiA9IChwcm9wczogYW55KSA9PiAoXG4gIDxTdmcgc2l6ZT17MjB9IHsuLi5wcm9wc30+XG4gICAgPHBhdGggZD1cIk00LjUxNiA3LjU0OGMwLjQzNi0wLjQ0NiAxLjA0My0wLjQ4MSAxLjU3NiAwbDMuOTA4IDMuNzQ3IDMuOTA4LTMuNzQ3YzAuNTMzLTAuNDgxIDEuMTQxLTAuNDQ2IDEuNTc0IDAgMC40MzYgMC40NDUgMC40MDggMS4xOTcgMCAxLjYxNS0wLjQwNiAwLjQxOC00LjY5NSA0LjUwMi00LjY5NSA0LjUwMi0wLjIxNyAwLjIyMy0wLjUwMiAwLjMzNS0wLjc4NyAwLjMzNXMtMC41Ny0wLjExMi0wLjc4OS0wLjMzNWMwIDAtNC4yODctNC4wODQtNC42OTUtNC41MDJzLTAuNDM2LTEuMTcgMC0xLjYxNXpcIiAvPlxuICA8L1N2Zz5cbik7XG5cbi8vID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxuLy8gRHJvcGRvd24gJiBDbGVhciBCdXR0b25zXG4vLyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT1cblxuZXhwb3J0IHR5cGUgSW5kaWNhdG9yUHJvcHMgPSBDb21tb25Qcm9wcyAmIHtcbiAgLyoqIFRoZSBjaGlsZHJlbiB0byBiZSByZW5kZXJlZCBpbnNpZGUgdGhlIGluZGljYXRvci4gKi9cbiAgY2hpbGRyZW46IE5vZGUsXG4gIC8qKiBQcm9wcyB0aGF0IHdpbGwgYmUgcGFzc2VkIG9uIHRvIHRoZSBjaGlsZHJlbi4gKi9cbiAgaW5uZXJQcm9wczogYW55LFxuICAvKiogVGhlIGZvY3VzZWQgc3RhdGUgb2YgdGhlIHNlbGVjdC4gKi9cbiAgaXNGb2N1c2VkOiBib29sZWFuLFxuICAvKiogV2hldGhlciB0aGUgdGV4dCBpcyByaWdodCB0byBsZWZ0ICovXG4gIGlzUnRsOiBib29sZWFuLFxufTtcblxuY29uc3QgYmFzZUNTUyA9ICh7XG4gIGlzRm9jdXNlZCxcbiAgdGhlbWU6IHtcbiAgICBzcGFjaW5nOiB7IGJhc2VVbml0IH0sXG4gICAgY29sb3JzLFxuICB9LFxufTogSW5kaWNhdG9yUHJvcHMpID0+ICh7XG4gIGxhYmVsOiAnaW5kaWNhdG9yQ29udGFpbmVyJyxcbiAgY29sb3I6IGlzRm9jdXNlZCA/IGNvbG9ycy5uZXV0cmFsNjAgOiBjb2xvcnMubmV1dHJhbDIwLFxuICBkaXNwbGF5OiAnZmxleCcsXG4gIHBhZGRpbmc6IGJhc2VVbml0ICogMixcbiAgdHJhbnNpdGlvbjogJ2NvbG9yIDE1MG1zJyxcblxuICAnOmhvdmVyJzoge1xuICAgIGNvbG9yOiBpc0ZvY3VzZWQgPyBjb2xvcnMubmV1dHJhbDgwIDogY29sb3JzLm5ldXRyYWw0MCxcbiAgfSxcbn0pO1xuXG5leHBvcnQgY29uc3QgZHJvcGRvd25JbmRpY2F0b3JDU1MgPSBiYXNlQ1NTO1xuZXhwb3J0IGNvbnN0IERyb3Bkb3duSW5kaWNhdG9yID0gKHByb3BzOiBJbmRpY2F0b3JQcm9wcykgPT4ge1xuICBjb25zdCB7IGNoaWxkcmVuLCBjbGFzc05hbWUsIGN4LCBnZXRTdHlsZXMsIGlubmVyUHJvcHMgfSA9IHByb3BzO1xuICByZXR1cm4gKFxuICAgIDxkaXZcbiAgICAgIHsuLi5pbm5lclByb3BzfVxuICAgICAgY3NzPXtnZXRTdHlsZXMoJ2Ryb3Bkb3duSW5kaWNhdG9yJywgcHJvcHMpfVxuICAgICAgY2xhc3NOYW1lPXtjeChcbiAgICAgICAge1xuICAgICAgICAgIGluZGljYXRvcjogdHJ1ZSxcbiAgICAgICAgICAnZHJvcGRvd24taW5kaWNhdG9yJzogdHJ1ZSxcbiAgICAgICAgfSxcbiAgICAgICAgY2xhc3NOYW1lXG4gICAgICApfVxuICAgID5cbiAgICAgIHtjaGlsZHJlbiB8fCA8RG93bkNoZXZyb24gLz59XG4gICAgPC9kaXY+XG4gICk7XG59O1xuXG5leHBvcnQgY29uc3QgY2xlYXJJbmRpY2F0b3JDU1MgPSBiYXNlQ1NTO1xuZXhwb3J0IGNvbnN0IENsZWFySW5kaWNhdG9yID0gKHByb3BzOiBJbmRpY2F0b3JQcm9wcykgPT4ge1xuICBjb25zdCB7IGNoaWxkcmVuLCBjbGFzc05hbWUsIGN4LCBnZXRTdHlsZXMsIGlubmVyUHJvcHMgfSA9IHByb3BzO1xuICByZXR1cm4gKFxuICAgIDxkaXZcbiAgICAgIHsuLi5pbm5lclByb3BzfVxuICAgICAgY3NzPXtnZXRTdHlsZXMoJ2NsZWFySW5kaWNhdG9yJywgcHJvcHMpfVxuICAgICAgY2xhc3NOYW1lPXtjeChcbiAgICAgICAge1xuICAgICAgICAgIGluZGljYXRvcjogdHJ1ZSxcbiAgICAgICAgICAnY2xlYXItaW5kaWNhdG9yJzogdHJ1ZSxcbiAgICAgICAgfSxcbiAgICAgICAgY2xhc3NOYW1lXG4gICAgICApfVxuICAgID5cbiAgICAgIHtjaGlsZHJlbiB8fCA8Q3Jvc3NJY29uIC8+fVxuICAgIDwvZGl2PlxuICApO1xufTtcblxuLy8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XG4vLyBTZXBhcmF0b3Jcbi8vID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxuXG50eXBlIFNlcGFyYXRvclN0YXRlID0geyBpc0Rpc2FibGVkOiBib29sZWFuIH07XG5cbmV4cG9ydCBjb25zdCBpbmRpY2F0b3JTZXBhcmF0b3JDU1MgPSAoe1xuICBpc0Rpc2FibGVkLFxuICB0aGVtZToge1xuICAgIHNwYWNpbmc6IHsgYmFzZVVuaXQgfSxcbiAgICBjb2xvcnMsXG4gIH0sXG59OiBDb21tb25Qcm9wcyAmIFNlcGFyYXRvclN0YXRlKSA9PiAoe1xuICBsYWJlbDogJ2luZGljYXRvclNlcGFyYXRvcicsXG4gIGFsaWduU2VsZjogJ3N0cmV0Y2gnLFxuICBiYWNrZ3JvdW5kQ29sb3I6IGlzRGlzYWJsZWQgPyBjb2xvcnMubmV1dHJhbDEwIDogY29sb3JzLm5ldXRyYWwyMCxcbiAgbWFyZ2luQm90dG9tOiBiYXNlVW5pdCAqIDIsXG4gIG1hcmdpblRvcDogYmFzZVVuaXQgKiAyLFxuICB3aWR0aDogMSxcbn0pO1xuXG5leHBvcnQgY29uc3QgSW5kaWNhdG9yU2VwYXJhdG9yID0gKHByb3BzOiBJbmRpY2F0b3JQcm9wcykgPT4ge1xuICBjb25zdCB7IGNsYXNzTmFtZSwgY3gsIGdldFN0eWxlcywgaW5uZXJQcm9wcyB9ID0gcHJvcHM7XG4gIHJldHVybiAoXG4gICAgPHNwYW5cbiAgICAgIHsuLi5pbm5lclByb3BzfVxuICAgICAgY3NzPXtnZXRTdHlsZXMoJ2luZGljYXRvclNlcGFyYXRvcicsIHByb3BzKX1cbiAgICAgIGNsYXNzTmFtZT17Y3goeyAnaW5kaWNhdG9yLXNlcGFyYXRvcic6IHRydWUgfSwgY2xhc3NOYW1lKX1cbiAgICAvPlxuICApO1xufTtcblxuLy8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XG4vLyBMb2FkaW5nXG4vLyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT1cblxuY29uc3QgbG9hZGluZ0RvdEFuaW1hdGlvbnMgPSBrZXlmcmFtZXNgXG4gIDAlLCA4MCUsIDEwMCUgeyBvcGFjaXR5OiAwOyB9XG4gIDQwJSB7IG9wYWNpdHk6IDE7IH1cbmA7XG5cbmV4cG9ydCBjb25zdCBsb2FkaW5nSW5kaWNhdG9yQ1NTID0gKHtcbiAgaXNGb2N1c2VkLFxuICBzaXplLFxuICB0aGVtZToge1xuICAgIGNvbG9ycyxcbiAgICBzcGFjaW5nOiB7IGJhc2VVbml0IH0sXG4gIH0sXG59OiB7XG4gIGlzRm9jdXNlZDogYm9vbGVhbixcbiAgc2l6ZTogbnVtYmVyLFxuICB0aGVtZTogVGhlbWUsXG59KSA9PiAoe1xuICBsYWJlbDogJ2xvYWRpbmdJbmRpY2F0b3InLFxuICBjb2xvcjogaXNGb2N1c2VkID8gY29sb3JzLm5ldXRyYWw2MCA6IGNvbG9ycy5uZXV0cmFsMjAsXG4gIGRpc3BsYXk6ICdmbGV4JyxcbiAgcGFkZGluZzogYmFzZVVuaXQgKiAyLFxuICB0cmFuc2l0aW9uOiAnY29sb3IgMTUwbXMnLFxuICBhbGlnblNlbGY6ICdjZW50ZXInLFxuICBmb250U2l6ZTogc2l6ZSxcbiAgbGluZUhlaWdodDogMSxcbiAgbWFyZ2luUmlnaHQ6IHNpemUsXG4gIHRleHRBbGlnbjogJ2NlbnRlcicsXG4gIHZlcnRpY2FsQWxpZ246ICdtaWRkbGUnLFxufSk7XG5cbnR5cGUgRG90UHJvcHMgPSB7IGRlbGF5OiBudW1iZXIsIG9mZnNldDogYm9vbGVhbiB9O1xuY29uc3QgTG9hZGluZ0RvdCA9ICh7IGRlbGF5LCBvZmZzZXQgfTogRG90UHJvcHMpID0+IChcbiAgPHNwYW5cbiAgICBjc3M9e3tcbiAgICAgIGFuaW1hdGlvbjogYCR7bG9hZGluZ0RvdEFuaW1hdGlvbnN9IDFzIGVhc2UtaW4tb3V0ICR7ZGVsYXl9bXMgaW5maW5pdGU7YCxcbiAgICAgIGJhY2tncm91bmRDb2xvcjogJ2N1cnJlbnRDb2xvcicsXG4gICAgICBib3JkZXJSYWRpdXM6ICcxZW0nLFxuICAgICAgZGlzcGxheTogJ2lubGluZS1ibG9jaycsXG4gICAgICBtYXJnaW5MZWZ0OiBvZmZzZXQgPyAnMWVtJyA6IG51bGwsXG4gICAgICBoZWlnaHQ6ICcxZW0nLFxuICAgICAgdmVydGljYWxBbGlnbjogJ3RvcCcsXG4gICAgICB3aWR0aDogJzFlbScsXG4gICAgfX1cbiAgLz5cbik7XG5cbmV4cG9ydCB0eXBlIExvYWRpbmdJY29uUHJvcHMgPSB7XG4gIC8qKiBQcm9wcyB0aGF0IHdpbGwgYmUgcGFzc2VkIG9uIHRvIHRoZSBjaGlsZHJlbi4gKi9cbiAgaW5uZXJQcm9wczogYW55LFxuICAvKiogVGhlIGZvY3VzZWQgc3RhdGUgb2YgdGhlIHNlbGVjdC4gKi9cbiAgaXNGb2N1c2VkOiBib29sZWFuLFxuICAvKiogV2hldGhlciB0aGUgdGV4dCBpcyByaWdodCB0byBsZWZ0ICovXG4gIGlzUnRsOiBib29sZWFuLFxufSAmIENvbW1vblByb3BzICYge1xuICAgIC8qKiBTZXQgc2l6ZSBvZiB0aGUgY29udGFpbmVyLiAqL1xuICAgIHNpemU6IG51bWJlcixcbiAgfTtcbmV4cG9ydCBjb25zdCBMb2FkaW5nSW5kaWNhdG9yID0gKHByb3BzOiBMb2FkaW5nSWNvblByb3BzKSA9PiB7XG4gIGNvbnN0IHsgY2xhc3NOYW1lLCBjeCwgZ2V0U3R5bGVzLCBpbm5lclByb3BzLCBpc1J0bCB9ID0gcHJvcHM7XG5cbiAgcmV0dXJuIChcbiAgICA8ZGl2XG4gICAgICB7Li4uaW5uZXJQcm9wc31cbiAgICAgIGNzcz17Z2V0U3R5bGVzKCdsb2FkaW5nSW5kaWNhdG9yJywgcHJvcHMpfVxuICAgICAgY2xhc3NOYW1lPXtjeChcbiAgICAgICAge1xuICAgICAgICAgIGluZGljYXRvcjogdHJ1ZSxcbiAgICAgICAgICAnbG9hZGluZy1pbmRpY2F0b3InOiB0cnVlLFxuICAgICAgICB9LFxuICAgICAgICBjbGFzc05hbWVcbiAgICAgICl9XG4gICAgPlxuICAgICAgPExvYWRpbmdEb3QgZGVsYXk9ezB9IG9mZnNldD17aXNSdGx9IC8+XG4gICAgICA8TG9hZGluZ0RvdCBkZWxheT17MTYwfSBvZmZzZXQgLz5cbiAgICAgIDxMb2FkaW5nRG90IGRlbGF5PXszMjB9IG9mZnNldD17IWlzUnRsfSAvPlxuICAgIDwvZGl2PlxuICApO1xufTtcbkxvYWRpbmdJbmRpY2F0b3IuZGVmYXVsdFByb3BzID0geyBzaXplOiA0IH07XG4iXX0= */"
};

// ==============================
// Dropdown & Clear Icons
// ==============================
var Svg = function Svg(_ref) {
  var size = _ref.size,
      props = _objectWithoutPropertiesLoose(_ref, ["size"]);

  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("svg", _extends$2({
    height: size,
    width: size,
    viewBox: "0 0 20 20",
    "aria-hidden": "true",
    focusable: "false",
    css: _ref2
  }, props));
};

var CrossIcon = function CrossIcon(props) {
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])(Svg, _extends$2({
    size: 20
  }, props), Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("path", {
    d: "M14.348 14.849c-0.469 0.469-1.229 0.469-1.697 0l-2.651-3.030-2.651 3.029c-0.469 0.469-1.229 0.469-1.697 0-0.469-0.469-0.469-1.229 0-1.697l2.758-3.15-2.759-3.152c-0.469-0.469-0.469-1.228 0-1.697s1.228-0.469 1.697 0l2.652 3.031 2.651-3.031c0.469-0.469 1.228-0.469 1.697 0s0.469 1.229 0 1.697l-2.758 3.152 2.758 3.15c0.469 0.469 0.469 1.229 0 1.698z"
  }));
};
var DownChevron = function DownChevron(props) {
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])(Svg, _extends$2({
    size: 20
  }, props), Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("path", {
    d: "M4.516 7.548c0.436-0.446 1.043-0.481 1.576 0l3.908 3.747 3.908-3.747c0.533-0.481 1.141-0.446 1.574 0 0.436 0.445 0.408 1.197 0 1.615-0.406 0.418-4.695 4.502-4.695 4.502-0.217 0.223-0.502 0.335-0.787 0.335s-0.57-0.112-0.789-0.335c0 0-4.287-4.084-4.695-4.502s-0.436-1.17 0-1.615z"
  }));
}; // ==============================
// Dropdown & Clear Buttons
// ==============================

var baseCSS = function baseCSS(_ref3) {
  var isFocused = _ref3.isFocused,
      _ref3$theme = _ref3.theme,
      baseUnit = _ref3$theme.spacing.baseUnit,
      colors = _ref3$theme.colors;
  return {
    label: 'indicatorContainer',
    color: isFocused ? colors.neutral60 : colors.neutral20,
    display: 'flex',
    padding: baseUnit * 2,
    transition: 'color 150ms',
    ':hover': {
      color: isFocused ? colors.neutral80 : colors.neutral40
    }
  };
};

var dropdownIndicatorCSS = baseCSS;
var DropdownIndicator = function DropdownIndicator(props) {
  var children = props.children,
      className = props.className,
      cx = props.cx,
      getStyles = props.getStyles,
      innerProps = props.innerProps;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", _extends$2({}, innerProps, {
    css: getStyles('dropdownIndicator', props),
    className: cx({
      indicator: true,
      'dropdown-indicator': true
    }, className)
  }), children || Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])(DownChevron, null));
};
var clearIndicatorCSS = baseCSS;
var ClearIndicator = function ClearIndicator(props) {
  var children = props.children,
      className = props.className,
      cx = props.cx,
      getStyles = props.getStyles,
      innerProps = props.innerProps;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", _extends$2({}, innerProps, {
    css: getStyles('clearIndicator', props),
    className: cx({
      indicator: true,
      'clear-indicator': true
    }, className)
  }), children || Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])(CrossIcon, null));
}; // ==============================
// Separator
// ==============================

var indicatorSeparatorCSS = function indicatorSeparatorCSS(_ref4) {
  var isDisabled = _ref4.isDisabled,
      _ref4$theme = _ref4.theme,
      baseUnit = _ref4$theme.spacing.baseUnit,
      colors = _ref4$theme.colors;
  return {
    label: 'indicatorSeparator',
    alignSelf: 'stretch',
    backgroundColor: isDisabled ? colors.neutral10 : colors.neutral20,
    marginBottom: baseUnit * 2,
    marginTop: baseUnit * 2,
    width: 1
  };
};
var IndicatorSeparator = function IndicatorSeparator(props) {
  var className = props.className,
      cx = props.cx,
      getStyles = props.getStyles,
      innerProps = props.innerProps;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("span", _extends$2({}, innerProps, {
    css: getStyles('indicatorSeparator', props),
    className: cx({
      'indicator-separator': true
    }, className)
  }));
}; // ==============================
// Loading
// ==============================

var loadingDotAnimations = Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["keyframes"])(_templateObject());
var loadingIndicatorCSS = function loadingIndicatorCSS(_ref5) {
  var isFocused = _ref5.isFocused,
      size = _ref5.size,
      _ref5$theme = _ref5.theme,
      colors = _ref5$theme.colors,
      baseUnit = _ref5$theme.spacing.baseUnit;
  return {
    label: 'loadingIndicator',
    color: isFocused ? colors.neutral60 : colors.neutral20,
    display: 'flex',
    padding: baseUnit * 2,
    transition: 'color 150ms',
    alignSelf: 'center',
    fontSize: size,
    lineHeight: 1,
    marginRight: size,
    textAlign: 'center',
    verticalAlign: 'middle'
  };
};

var LoadingDot = function LoadingDot(_ref6) {
  var delay = _ref6.delay,
      offset = _ref6.offset;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("span", {
    css:
    /*#__PURE__*/
    Object(_emotion_css__WEBPACK_IMPORTED_MODULE_5__["default"])({
      animation: loadingDotAnimations + " 1s ease-in-out " + delay + "ms infinite;",
      backgroundColor: 'currentColor',
      borderRadius: '1em',
      display: 'inline-block',
      marginLeft: offset ? '1em' : null,
      height: '1em',
      verticalAlign: 'top',
      width: '1em'
    },  false ? undefined : "/*# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbImluZGljYXRvcnMuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBc0xJIiwiZmlsZSI6ImluZGljYXRvcnMuanMiLCJzb3VyY2VzQ29udGVudCI6WyIvLyBAZmxvd1xuLyoqIEBqc3gganN4ICovXG5pbXBvcnQgeyB0eXBlIE5vZGUgfSBmcm9tICdyZWFjdCc7XG5pbXBvcnQgeyBqc3gsIGtleWZyYW1lcyB9IGZyb20gJ0BlbW90aW9uL2NvcmUnO1xuXG5pbXBvcnQgdHlwZSB7IENvbW1vblByb3BzLCBUaGVtZSB9IGZyb20gJy4uL3R5cGVzJztcblxuLy8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XG4vLyBEcm9wZG93biAmIENsZWFyIEljb25zXG4vLyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT1cblxuY29uc3QgU3ZnID0gKHsgc2l6ZSwgLi4ucHJvcHMgfTogeyBzaXplOiBudW1iZXIgfSkgPT4gKFxuICA8c3ZnXG4gICAgaGVpZ2h0PXtzaXplfVxuICAgIHdpZHRoPXtzaXplfVxuICAgIHZpZXdCb3g9XCIwIDAgMjAgMjBcIlxuICAgIGFyaWEtaGlkZGVuPVwidHJ1ZVwiXG4gICAgZm9jdXNhYmxlPVwiZmFsc2VcIlxuICAgIGNzcz17e1xuICAgICAgZGlzcGxheTogJ2lubGluZS1ibG9jaycsXG4gICAgICBmaWxsOiAnY3VycmVudENvbG9yJyxcbiAgICAgIGxpbmVIZWlnaHQ6IDEsXG4gICAgICBzdHJva2U6ICdjdXJyZW50Q29sb3InLFxuICAgICAgc3Ryb2tlV2lkdGg6IDAsXG4gICAgfX1cbiAgICB7Li4ucHJvcHN9XG4gIC8+XG4pO1xuXG5leHBvcnQgY29uc3QgQ3Jvc3NJY29uID0gKHByb3BzOiBhbnkpID0+IChcbiAgPFN2ZyBzaXplPXsyMH0gey4uLnByb3BzfT5cbiAgICA8cGF0aCBkPVwiTTE0LjM0OCAxNC44NDljLTAuNDY5IDAuNDY5LTEuMjI5IDAuNDY5LTEuNjk3IDBsLTIuNjUxLTMuMDMwLTIuNjUxIDMuMDI5Yy0wLjQ2OSAwLjQ2OS0xLjIyOSAwLjQ2OS0xLjY5NyAwLTAuNDY5LTAuNDY5LTAuNDY5LTEuMjI5IDAtMS42OTdsMi43NTgtMy4xNS0yLjc1OS0zLjE1MmMtMC40NjktMC40NjktMC40NjktMS4yMjggMC0xLjY5N3MxLjIyOC0wLjQ2OSAxLjY5NyAwbDIuNjUyIDMuMDMxIDIuNjUxLTMuMDMxYzAuNDY5LTAuNDY5IDEuMjI4LTAuNDY5IDEuNjk3IDBzMC40NjkgMS4yMjkgMCAxLjY5N2wtMi43NTggMy4xNTIgMi43NTggMy4xNWMwLjQ2OSAwLjQ2OSAwLjQ2OSAxLjIyOSAwIDEuNjk4elwiIC8+XG4gIDwvU3ZnPlxuKTtcbmV4cG9ydCBjb25zdCBEb3duQ2hldnJvbiA9IChwcm9wczogYW55KSA9PiAoXG4gIDxTdmcgc2l6ZT17MjB9IHsuLi5wcm9wc30+XG4gICAgPHBhdGggZD1cIk00LjUxNiA3LjU0OGMwLjQzNi0wLjQ0NiAxLjA0My0wLjQ4MSAxLjU3NiAwbDMuOTA4IDMuNzQ3IDMuOTA4LTMuNzQ3YzAuNTMzLTAuNDgxIDEuMTQxLTAuNDQ2IDEuNTc0IDAgMC40MzYgMC40NDUgMC40MDggMS4xOTcgMCAxLjYxNS0wLjQwNiAwLjQxOC00LjY5NSA0LjUwMi00LjY5NSA0LjUwMi0wLjIxNyAwLjIyMy0wLjUwMiAwLjMzNS0wLjc4NyAwLjMzNXMtMC41Ny0wLjExMi0wLjc4OS0wLjMzNWMwIDAtNC4yODctNC4wODQtNC42OTUtNC41MDJzLTAuNDM2LTEuMTcgMC0xLjYxNXpcIiAvPlxuICA8L1N2Zz5cbik7XG5cbi8vID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxuLy8gRHJvcGRvd24gJiBDbGVhciBCdXR0b25zXG4vLyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT1cblxuZXhwb3J0IHR5cGUgSW5kaWNhdG9yUHJvcHMgPSBDb21tb25Qcm9wcyAmIHtcbiAgLyoqIFRoZSBjaGlsZHJlbiB0byBiZSByZW5kZXJlZCBpbnNpZGUgdGhlIGluZGljYXRvci4gKi9cbiAgY2hpbGRyZW46IE5vZGUsXG4gIC8qKiBQcm9wcyB0aGF0IHdpbGwgYmUgcGFzc2VkIG9uIHRvIHRoZSBjaGlsZHJlbi4gKi9cbiAgaW5uZXJQcm9wczogYW55LFxuICAvKiogVGhlIGZvY3VzZWQgc3RhdGUgb2YgdGhlIHNlbGVjdC4gKi9cbiAgaXNGb2N1c2VkOiBib29sZWFuLFxuICAvKiogV2hldGhlciB0aGUgdGV4dCBpcyByaWdodCB0byBsZWZ0ICovXG4gIGlzUnRsOiBib29sZWFuLFxufTtcblxuY29uc3QgYmFzZUNTUyA9ICh7XG4gIGlzRm9jdXNlZCxcbiAgdGhlbWU6IHtcbiAgICBzcGFjaW5nOiB7IGJhc2VVbml0IH0sXG4gICAgY29sb3JzLFxuICB9LFxufTogSW5kaWNhdG9yUHJvcHMpID0+ICh7XG4gIGxhYmVsOiAnaW5kaWNhdG9yQ29udGFpbmVyJyxcbiAgY29sb3I6IGlzRm9jdXNlZCA/IGNvbG9ycy5uZXV0cmFsNjAgOiBjb2xvcnMubmV1dHJhbDIwLFxuICBkaXNwbGF5OiAnZmxleCcsXG4gIHBhZGRpbmc6IGJhc2VVbml0ICogMixcbiAgdHJhbnNpdGlvbjogJ2NvbG9yIDE1MG1zJyxcblxuICAnOmhvdmVyJzoge1xuICAgIGNvbG9yOiBpc0ZvY3VzZWQgPyBjb2xvcnMubmV1dHJhbDgwIDogY29sb3JzLm5ldXRyYWw0MCxcbiAgfSxcbn0pO1xuXG5leHBvcnQgY29uc3QgZHJvcGRvd25JbmRpY2F0b3JDU1MgPSBiYXNlQ1NTO1xuZXhwb3J0IGNvbnN0IERyb3Bkb3duSW5kaWNhdG9yID0gKHByb3BzOiBJbmRpY2F0b3JQcm9wcykgPT4ge1xuICBjb25zdCB7IGNoaWxkcmVuLCBjbGFzc05hbWUsIGN4LCBnZXRTdHlsZXMsIGlubmVyUHJvcHMgfSA9IHByb3BzO1xuICByZXR1cm4gKFxuICAgIDxkaXZcbiAgICAgIHsuLi5pbm5lclByb3BzfVxuICAgICAgY3NzPXtnZXRTdHlsZXMoJ2Ryb3Bkb3duSW5kaWNhdG9yJywgcHJvcHMpfVxuICAgICAgY2xhc3NOYW1lPXtjeChcbiAgICAgICAge1xuICAgICAgICAgIGluZGljYXRvcjogdHJ1ZSxcbiAgICAgICAgICAnZHJvcGRvd24taW5kaWNhdG9yJzogdHJ1ZSxcbiAgICAgICAgfSxcbiAgICAgICAgY2xhc3NOYW1lXG4gICAgICApfVxuICAgID5cbiAgICAgIHtjaGlsZHJlbiB8fCA8RG93bkNoZXZyb24gLz59XG4gICAgPC9kaXY+XG4gICk7XG59O1xuXG5leHBvcnQgY29uc3QgY2xlYXJJbmRpY2F0b3JDU1MgPSBiYXNlQ1NTO1xuZXhwb3J0IGNvbnN0IENsZWFySW5kaWNhdG9yID0gKHByb3BzOiBJbmRpY2F0b3JQcm9wcykgPT4ge1xuICBjb25zdCB7IGNoaWxkcmVuLCBjbGFzc05hbWUsIGN4LCBnZXRTdHlsZXMsIGlubmVyUHJvcHMgfSA9IHByb3BzO1xuICByZXR1cm4gKFxuICAgIDxkaXZcbiAgICAgIHsuLi5pbm5lclByb3BzfVxuICAgICAgY3NzPXtnZXRTdHlsZXMoJ2NsZWFySW5kaWNhdG9yJywgcHJvcHMpfVxuICAgICAgY2xhc3NOYW1lPXtjeChcbiAgICAgICAge1xuICAgICAgICAgIGluZGljYXRvcjogdHJ1ZSxcbiAgICAgICAgICAnY2xlYXItaW5kaWNhdG9yJzogdHJ1ZSxcbiAgICAgICAgfSxcbiAgICAgICAgY2xhc3NOYW1lXG4gICAgICApfVxuICAgID5cbiAgICAgIHtjaGlsZHJlbiB8fCA8Q3Jvc3NJY29uIC8+fVxuICAgIDwvZGl2PlxuICApO1xufTtcblxuLy8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XG4vLyBTZXBhcmF0b3Jcbi8vID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxuXG50eXBlIFNlcGFyYXRvclN0YXRlID0geyBpc0Rpc2FibGVkOiBib29sZWFuIH07XG5cbmV4cG9ydCBjb25zdCBpbmRpY2F0b3JTZXBhcmF0b3JDU1MgPSAoe1xuICBpc0Rpc2FibGVkLFxuICB0aGVtZToge1xuICAgIHNwYWNpbmc6IHsgYmFzZVVuaXQgfSxcbiAgICBjb2xvcnMsXG4gIH0sXG59OiBDb21tb25Qcm9wcyAmIFNlcGFyYXRvclN0YXRlKSA9PiAoe1xuICBsYWJlbDogJ2luZGljYXRvclNlcGFyYXRvcicsXG4gIGFsaWduU2VsZjogJ3N0cmV0Y2gnLFxuICBiYWNrZ3JvdW5kQ29sb3I6IGlzRGlzYWJsZWQgPyBjb2xvcnMubmV1dHJhbDEwIDogY29sb3JzLm5ldXRyYWwyMCxcbiAgbWFyZ2luQm90dG9tOiBiYXNlVW5pdCAqIDIsXG4gIG1hcmdpblRvcDogYmFzZVVuaXQgKiAyLFxuICB3aWR0aDogMSxcbn0pO1xuXG5leHBvcnQgY29uc3QgSW5kaWNhdG9yU2VwYXJhdG9yID0gKHByb3BzOiBJbmRpY2F0b3JQcm9wcykgPT4ge1xuICBjb25zdCB7IGNsYXNzTmFtZSwgY3gsIGdldFN0eWxlcywgaW5uZXJQcm9wcyB9ID0gcHJvcHM7XG4gIHJldHVybiAoXG4gICAgPHNwYW5cbiAgICAgIHsuLi5pbm5lclByb3BzfVxuICAgICAgY3NzPXtnZXRTdHlsZXMoJ2luZGljYXRvclNlcGFyYXRvcicsIHByb3BzKX1cbiAgICAgIGNsYXNzTmFtZT17Y3goeyAnaW5kaWNhdG9yLXNlcGFyYXRvcic6IHRydWUgfSwgY2xhc3NOYW1lKX1cbiAgICAvPlxuICApO1xufTtcblxuLy8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XG4vLyBMb2FkaW5nXG4vLyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT1cblxuY29uc3QgbG9hZGluZ0RvdEFuaW1hdGlvbnMgPSBrZXlmcmFtZXNgXG4gIDAlLCA4MCUsIDEwMCUgeyBvcGFjaXR5OiAwOyB9XG4gIDQwJSB7IG9wYWNpdHk6IDE7IH1cbmA7XG5cbmV4cG9ydCBjb25zdCBsb2FkaW5nSW5kaWNhdG9yQ1NTID0gKHtcbiAgaXNGb2N1c2VkLFxuICBzaXplLFxuICB0aGVtZToge1xuICAgIGNvbG9ycyxcbiAgICBzcGFjaW5nOiB7IGJhc2VVbml0IH0sXG4gIH0sXG59OiB7XG4gIGlzRm9jdXNlZDogYm9vbGVhbixcbiAgc2l6ZTogbnVtYmVyLFxuICB0aGVtZTogVGhlbWUsXG59KSA9PiAoe1xuICBsYWJlbDogJ2xvYWRpbmdJbmRpY2F0b3InLFxuICBjb2xvcjogaXNGb2N1c2VkID8gY29sb3JzLm5ldXRyYWw2MCA6IGNvbG9ycy5uZXV0cmFsMjAsXG4gIGRpc3BsYXk6ICdmbGV4JyxcbiAgcGFkZGluZzogYmFzZVVuaXQgKiAyLFxuICB0cmFuc2l0aW9uOiAnY29sb3IgMTUwbXMnLFxuICBhbGlnblNlbGY6ICdjZW50ZXInLFxuICBmb250U2l6ZTogc2l6ZSxcbiAgbGluZUhlaWdodDogMSxcbiAgbWFyZ2luUmlnaHQ6IHNpemUsXG4gIHRleHRBbGlnbjogJ2NlbnRlcicsXG4gIHZlcnRpY2FsQWxpZ246ICdtaWRkbGUnLFxufSk7XG5cbnR5cGUgRG90UHJvcHMgPSB7IGRlbGF5OiBudW1iZXIsIG9mZnNldDogYm9vbGVhbiB9O1xuY29uc3QgTG9hZGluZ0RvdCA9ICh7IGRlbGF5LCBvZmZzZXQgfTogRG90UHJvcHMpID0+IChcbiAgPHNwYW5cbiAgICBjc3M9e3tcbiAgICAgIGFuaW1hdGlvbjogYCR7bG9hZGluZ0RvdEFuaW1hdGlvbnN9IDFzIGVhc2UtaW4tb3V0ICR7ZGVsYXl9bXMgaW5maW5pdGU7YCxcbiAgICAgIGJhY2tncm91bmRDb2xvcjogJ2N1cnJlbnRDb2xvcicsXG4gICAgICBib3JkZXJSYWRpdXM6ICcxZW0nLFxuICAgICAgZGlzcGxheTogJ2lubGluZS1ibG9jaycsXG4gICAgICBtYXJnaW5MZWZ0OiBvZmZzZXQgPyAnMWVtJyA6IG51bGwsXG4gICAgICBoZWlnaHQ6ICcxZW0nLFxuICAgICAgdmVydGljYWxBbGlnbjogJ3RvcCcsXG4gICAgICB3aWR0aDogJzFlbScsXG4gICAgfX1cbiAgLz5cbik7XG5cbmV4cG9ydCB0eXBlIExvYWRpbmdJY29uUHJvcHMgPSB7XG4gIC8qKiBQcm9wcyB0aGF0IHdpbGwgYmUgcGFzc2VkIG9uIHRvIHRoZSBjaGlsZHJlbi4gKi9cbiAgaW5uZXJQcm9wczogYW55LFxuICAvKiogVGhlIGZvY3VzZWQgc3RhdGUgb2YgdGhlIHNlbGVjdC4gKi9cbiAgaXNGb2N1c2VkOiBib29sZWFuLFxuICAvKiogV2hldGhlciB0aGUgdGV4dCBpcyByaWdodCB0byBsZWZ0ICovXG4gIGlzUnRsOiBib29sZWFuLFxufSAmIENvbW1vblByb3BzICYge1xuICAgIC8qKiBTZXQgc2l6ZSBvZiB0aGUgY29udGFpbmVyLiAqL1xuICAgIHNpemU6IG51bWJlcixcbiAgfTtcbmV4cG9ydCBjb25zdCBMb2FkaW5nSW5kaWNhdG9yID0gKHByb3BzOiBMb2FkaW5nSWNvblByb3BzKSA9PiB7XG4gIGNvbnN0IHsgY2xhc3NOYW1lLCBjeCwgZ2V0U3R5bGVzLCBpbm5lclByb3BzLCBpc1J0bCB9ID0gcHJvcHM7XG5cbiAgcmV0dXJuIChcbiAgICA8ZGl2XG4gICAgICB7Li4uaW5uZXJQcm9wc31cbiAgICAgIGNzcz17Z2V0U3R5bGVzKCdsb2FkaW5nSW5kaWNhdG9yJywgcHJvcHMpfVxuICAgICAgY2xhc3NOYW1lPXtjeChcbiAgICAgICAge1xuICAgICAgICAgIGluZGljYXRvcjogdHJ1ZSxcbiAgICAgICAgICAnbG9hZGluZy1pbmRpY2F0b3InOiB0cnVlLFxuICAgICAgICB9LFxuICAgICAgICBjbGFzc05hbWVcbiAgICAgICl9XG4gICAgPlxuICAgICAgPExvYWRpbmdEb3QgZGVsYXk9ezB9IG9mZnNldD17aXNSdGx9IC8+XG4gICAgICA8TG9hZGluZ0RvdCBkZWxheT17MTYwfSBvZmZzZXQgLz5cbiAgICAgIDxMb2FkaW5nRG90IGRlbGF5PXszMjB9IG9mZnNldD17IWlzUnRsfSAvPlxuICAgIDwvZGl2PlxuICApO1xufTtcbkxvYWRpbmdJbmRpY2F0b3IuZGVmYXVsdFByb3BzID0geyBzaXplOiA0IH07XG4iXX0= */")
  });
};

var LoadingIndicator = function LoadingIndicator(props) {
  var className = props.className,
      cx = props.cx,
      getStyles = props.getStyles,
      innerProps = props.innerProps,
      isRtl = props.isRtl;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", _extends$2({}, innerProps, {
    css: getStyles('loadingIndicator', props),
    className: cx({
      indicator: true,
      'loading-indicator': true
    }, className)
  }), Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])(LoadingDot, {
    delay: 0,
    offset: isRtl
  }), Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])(LoadingDot, {
    delay: 160,
    offset: true
  }), Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])(LoadingDot, {
    delay: 320,
    offset: !isRtl
  }));
};
LoadingIndicator.defaultProps = {
  size: 4
};

function _extends$3() { _extends$3 = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends$3.apply(this, arguments); }
var css = function css(_ref) {
  var isDisabled = _ref.isDisabled,
      isFocused = _ref.isFocused,
      _ref$theme = _ref.theme,
      colors = _ref$theme.colors,
      borderRadius = _ref$theme.borderRadius,
      spacing = _ref$theme.spacing;
  return {
    label: 'control',
    alignItems: 'center',
    backgroundColor: isDisabled ? colors.neutral5 : colors.neutral0,
    borderColor: isDisabled ? colors.neutral10 : isFocused ? colors.primary : colors.neutral20,
    borderRadius: borderRadius,
    borderStyle: 'solid',
    borderWidth: 1,
    boxShadow: isFocused ? "0 0 0 1px " + colors.primary : null,
    cursor: 'default',
    display: 'flex',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    minHeight: spacing.controlHeight,
    outline: '0 !important',
    position: 'relative',
    transition: 'all 100ms',
    '&:hover': {
      borderColor: isFocused ? colors.primary : colors.neutral30
    }
  };
};

var Control = function Control(props) {
  var children = props.children,
      cx = props.cx,
      getStyles = props.getStyles,
      className = props.className,
      isDisabled = props.isDisabled,
      isFocused = props.isFocused,
      innerRef = props.innerRef,
      innerProps = props.innerProps,
      menuIsOpen = props.menuIsOpen;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", _extends$3({
    ref: innerRef,
    css: getStyles('control', props),
    className: cx({
      control: true,
      'control--is-disabled': isDisabled,
      'control--is-focused': isFocused,
      'control--menu-is-open': menuIsOpen
    }, className)
  }, innerProps), children);
};

function _objectWithoutPropertiesLoose$1(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _extends$4() { _extends$4 = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends$4.apply(this, arguments); }
var groupCSS = function groupCSS(_ref) {
  var spacing = _ref.theme.spacing;
  return {
    paddingBottom: spacing.baseUnit * 2,
    paddingTop: spacing.baseUnit * 2
  };
};

var Group = function Group(props) {
  var children = props.children,
      className = props.className,
      cx = props.cx,
      getStyles = props.getStyles,
      Heading = props.Heading,
      headingProps = props.headingProps,
      label = props.label,
      theme = props.theme,
      selectProps = props.selectProps;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", {
    css: getStyles('group', props),
    className: cx({
      group: true
    }, className)
  }, Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])(Heading, _extends$4({}, headingProps, {
    selectProps: selectProps,
    theme: theme,
    getStyles: getStyles,
    cx: cx
  }), label), Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", null, children));
};

var groupHeadingCSS = function groupHeadingCSS(_ref2) {
  var spacing = _ref2.theme.spacing;
  return {
    label: 'group',
    color: '#999',
    cursor: 'default',
    display: 'block',
    fontSize: '75%',
    fontWeight: '500',
    marginBottom: '0.25em',
    paddingLeft: spacing.baseUnit * 3,
    paddingRight: spacing.baseUnit * 3,
    textTransform: 'uppercase'
  };
};
var GroupHeading = function GroupHeading(props) {
  var className = props.className,
      cx = props.cx,
      getStyles = props.getStyles,
      theme = props.theme,
      selectProps = props.selectProps,
      cleanProps = _objectWithoutPropertiesLoose$1(props, ["className", "cx", "getStyles", "theme", "selectProps"]);

  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", _extends$4({
    css: getStyles('groupHeading', _extends$4({
      theme: theme
    }, cleanProps)),
    className: cx({
      'group-heading': true
    }, className)
  }, cleanProps));
};

function _extends$5() { _extends$5 = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends$5.apply(this, arguments); }

function _objectWithoutPropertiesLoose$2(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }
var inputCSS = function inputCSS(_ref) {
  var isDisabled = _ref.isDisabled,
      _ref$theme = _ref.theme,
      spacing = _ref$theme.spacing,
      colors = _ref$theme.colors;
  return {
    margin: spacing.baseUnit / 2,
    paddingBottom: spacing.baseUnit / 2,
    paddingTop: spacing.baseUnit / 2,
    visibility: isDisabled ? 'hidden' : 'visible',
    color: colors.neutral80
  };
};

var inputStyle = function inputStyle(isHidden) {
  return {
    label: 'input',
    background: 0,
    border: 0,
    fontSize: 'inherit',
    opacity: isHidden ? 0 : 1,
    outline: 0,
    padding: 0,
    color: 'inherit'
  };
};

var Input = function Input(_ref2) {
  var className = _ref2.className,
      cx = _ref2.cx,
      getStyles = _ref2.getStyles,
      innerRef = _ref2.innerRef,
      isHidden = _ref2.isHidden,
      isDisabled = _ref2.isDisabled,
      theme = _ref2.theme,
      selectProps = _ref2.selectProps,
      props = _objectWithoutPropertiesLoose$2(_ref2, ["className", "cx", "getStyles", "innerRef", "isHidden", "isDisabled", "theme", "selectProps"]);

  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", {
    css: getStyles('input', _extends$5({
      theme: theme
    }, props))
  }, Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])(react_input_autosize__WEBPACK_IMPORTED_MODULE_6___default.a, _extends$5({
    className: cx({
      input: true
    }, className),
    inputRef: innerRef,
    inputStyle: inputStyle(isHidden),
    disabled: isDisabled
  }, props)));
};

function _extends$6() { _extends$6 = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends$6.apply(this, arguments); }
var multiValueCSS = function multiValueCSS(_ref) {
  var _ref$theme = _ref.theme,
      spacing = _ref$theme.spacing,
      borderRadius = _ref$theme.borderRadius,
      colors = _ref$theme.colors;
  return {
    label: 'multiValue',
    backgroundColor: colors.neutral10,
    borderRadius: borderRadius / 2,
    display: 'flex',
    margin: spacing.baseUnit / 2,
    minWidth: 0 // resolves flex/text-overflow bug

  };
};
var multiValueLabelCSS = function multiValueLabelCSS(_ref2) {
  var _ref2$theme = _ref2.theme,
      borderRadius = _ref2$theme.borderRadius,
      colors = _ref2$theme.colors,
      cropWithEllipsis = _ref2.cropWithEllipsis;
  return {
    borderRadius: borderRadius / 2,
    color: colors.neutral80,
    fontSize: '85%',
    overflow: 'hidden',
    padding: 3,
    paddingLeft: 6,
    textOverflow: cropWithEllipsis ? 'ellipsis' : null,
    whiteSpace: 'nowrap'
  };
};
var multiValueRemoveCSS = function multiValueRemoveCSS(_ref3) {
  var _ref3$theme = _ref3.theme,
      spacing = _ref3$theme.spacing,
      borderRadius = _ref3$theme.borderRadius,
      colors = _ref3$theme.colors,
      isFocused = _ref3.isFocused;
  return {
    alignItems: 'center',
    borderRadius: borderRadius / 2,
    backgroundColor: isFocused && colors.dangerLight,
    display: 'flex',
    paddingLeft: spacing.baseUnit,
    paddingRight: spacing.baseUnit,
    ':hover': {
      backgroundColor: colors.dangerLight,
      color: colors.danger
    }
  };
};
var MultiValueGeneric = function MultiValueGeneric(_ref4) {
  var children = _ref4.children,
      innerProps = _ref4.innerProps;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", innerProps, children);
};
var MultiValueContainer = MultiValueGeneric;
var MultiValueLabel = MultiValueGeneric;
function MultiValueRemove(_ref5) {
  var children = _ref5.children,
      innerProps = _ref5.innerProps;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", innerProps, children || Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])(CrossIcon, {
    size: 14
  }));
}

var MultiValue = function MultiValue(props) {
  var children = props.children,
      className = props.className,
      components = props.components,
      cx = props.cx,
      data = props.data,
      getStyles = props.getStyles,
      innerProps = props.innerProps,
      isDisabled = props.isDisabled,
      removeProps = props.removeProps,
      selectProps = props.selectProps;
  var Container = components.Container,
      Label = components.Label,
      Remove = components.Remove;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["ClassNames"], null, function (_ref6) {
    var css = _ref6.css,
        emotionCx = _ref6.cx;
    return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])(Container, {
      data: data,
      innerProps: _extends$6({}, innerProps, {
        className: emotionCx(css(getStyles('multiValue', props)), cx({
          'multi-value': true,
          'multi-value--is-disabled': isDisabled
        }, className))
      }),
      selectProps: selectProps
    }, Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])(Label, {
      data: data,
      innerProps: {
        className: emotionCx(css(getStyles('multiValueLabel', props)), cx({
          'multi-value__label': true
        }, className))
      },
      selectProps: selectProps
    }, children), Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])(Remove, {
      data: data,
      innerProps: _extends$6({
        className: emotionCx(css(getStyles('multiValueRemove', props)), cx({
          'multi-value__remove': true
        }, className))
      }, removeProps),
      selectProps: selectProps
    }));
  });
};

MultiValue.defaultProps = {
  cropWithEllipsis: true
};

function _extends$7() { _extends$7 = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends$7.apply(this, arguments); }
var optionCSS = function optionCSS(_ref) {
  var isDisabled = _ref.isDisabled,
      isFocused = _ref.isFocused,
      isSelected = _ref.isSelected,
      _ref$theme = _ref.theme,
      spacing = _ref$theme.spacing,
      colors = _ref$theme.colors;
  return {
    label: 'option',
    backgroundColor: isSelected ? colors.primary : isFocused ? colors.primary25 : 'transparent',
    color: isDisabled ? colors.neutral20 : isSelected ? colors.neutral0 : 'inherit',
    cursor: 'default',
    display: 'block',
    fontSize: 'inherit',
    padding: spacing.baseUnit * 2 + "px " + spacing.baseUnit * 3 + "px",
    width: '100%',
    userSelect: 'none',
    WebkitTapHighlightColor: 'rgba(0, 0, 0, 0)',
    // provide some affordance on touch devices
    ':active': {
      backgroundColor: !isDisabled && (isSelected ? colors.primary : colors.primary50)
    }
  };
};

var Option = function Option(props) {
  var children = props.children,
      className = props.className,
      cx = props.cx,
      getStyles = props.getStyles,
      isDisabled = props.isDisabled,
      isFocused = props.isFocused,
      isSelected = props.isSelected,
      innerRef = props.innerRef,
      innerProps = props.innerProps;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", _extends$7({
    css: getStyles('option', props),
    className: cx({
      option: true,
      'option--is-disabled': isDisabled,
      'option--is-focused': isFocused,
      'option--is-selected': isSelected
    }, className),
    ref: innerRef
  }, innerProps), children);
};

function _extends$8() { _extends$8 = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends$8.apply(this, arguments); }
var placeholderCSS = function placeholderCSS(_ref) {
  var _ref$theme = _ref.theme,
      spacing = _ref$theme.spacing,
      colors = _ref$theme.colors;
  return {
    label: 'placeholder',
    color: colors.neutral50,
    marginLeft: spacing.baseUnit / 2,
    marginRight: spacing.baseUnit / 2,
    position: 'absolute',
    top: '50%',
    transform: 'translateY(-50%)'
  };
};

var Placeholder = function Placeholder(props) {
  var children = props.children,
      className = props.className,
      cx = props.cx,
      getStyles = props.getStyles,
      innerProps = props.innerProps;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", _extends$8({
    css: getStyles('placeholder', props),
    className: cx({
      placeholder: true
    }, className)
  }, innerProps), children);
};

function _extends$9() { _extends$9 = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends$9.apply(this, arguments); }
var css$1 = function css(_ref) {
  var isDisabled = _ref.isDisabled,
      _ref$theme = _ref.theme,
      spacing = _ref$theme.spacing,
      colors = _ref$theme.colors;
  return {
    label: 'singleValue',
    color: isDisabled ? colors.neutral40 : colors.neutral80,
    marginLeft: spacing.baseUnit / 2,
    marginRight: spacing.baseUnit / 2,
    maxWidth: "calc(100% - " + spacing.baseUnit * 2 + "px)",
    overflow: 'hidden',
    position: 'absolute',
    textOverflow: 'ellipsis',
    whiteSpace: 'nowrap',
    top: '50%',
    transform: 'translateY(-50%)'
  };
};

var SingleValue = function SingleValue(props) {
  var children = props.children,
      className = props.className,
      cx = props.cx,
      getStyles = props.getStyles,
      isDisabled = props.isDisabled,
      innerProps = props.innerProps;
  return Object(_emotion_core__WEBPACK_IMPORTED_MODULE_1__["jsx"])("div", _extends$9({
    css: getStyles('singleValue', props),
    className: cx({
      'single-value': true,
      'single-value--is-disabled': isDisabled
    }, className)
  }, innerProps), children);
};

function _extends$a() { _extends$a = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends$a.apply(this, arguments); }
var components = {
  ClearIndicator: ClearIndicator,
  Control: Control,
  DropdownIndicator: DropdownIndicator,
  DownChevron: DownChevron,
  CrossIcon: CrossIcon,
  Group: Group,
  GroupHeading: GroupHeading,
  IndicatorsContainer: IndicatorsContainer,
  IndicatorSeparator: IndicatorSeparator,
  Input: Input,
  LoadingIndicator: LoadingIndicator,
  Menu: Menu,
  MenuList: MenuList,
  MenuPortal: MenuPortal,
  LoadingMessage: LoadingMessage,
  NoOptionsMessage: NoOptionsMessage,
  MultiValue: MultiValue,
  MultiValueContainer: MultiValueContainer,
  MultiValueLabel: MultiValueLabel,
  MultiValueRemove: MultiValueRemove,
  Option: Option,
  Placeholder: Placeholder,
  SelectContainer: SelectContainer,
  SingleValue: SingleValue,
  ValueContainer: ValueContainer
};
var defaultComponents = function defaultComponents(props) {
  return _extends$a({}, components, props.components);
};




/***/ }),

/***/ "./node_modules/react-select/dist/react-select.browser.esm.js":
/*!********************************************************************!*\
  !*** ./node_modules/react-select/dist/react-select.browser.esm.js ***!
  \********************************************************************/
/*! exports provided: components, createFilter, defaultTheme, mergeStyles, default, NonceProvider */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "NonceProvider", function() { return NonceProvider; });
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var memoize_one__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! memoize-one */ "./node_modules/memoize-one/dist/memoize-one.esm.js");
/* harmony import */ var _emotion_core__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @emotion/core */ "./node_modules/@emotion/core/dist/core.browser.esm.js");
/* harmony import */ var react_dom__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! react-dom */ "react-dom");
/* harmony import */ var react_dom__WEBPACK_IMPORTED_MODULE_3___default = /*#__PURE__*/__webpack_require__.n(react_dom__WEBPACK_IMPORTED_MODULE_3__);
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! prop-types */ "./node_modules/prop-types/index.js");
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_4___default = /*#__PURE__*/__webpack_require__.n(prop_types__WEBPACK_IMPORTED_MODULE_4__);
/* harmony import */ var _utils_06b0d5a4_browser_esm_js__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ./utils-06b0d5a4.browser.esm.js */ "./node_modules/react-select/dist/utils-06b0d5a4.browser.esm.js");
/* harmony import */ var _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! ./index-4322c0ed.browser.esm.js */ "./node_modules/react-select/dist/index-4322c0ed.browser.esm.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "components", function() { return _index_4322c0ed_browser_esm_js__WEBPACK_IMPORTED_MODULE_6__["y"]; });

/* harmony import */ var _Select_9fdb8cd0_browser_esm_js__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! ./Select-9fdb8cd0.browser.esm.js */ "./node_modules/react-select/dist/Select-9fdb8cd0.browser.esm.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "createFilter", function() { return _Select_9fdb8cd0_browser_esm_js__WEBPACK_IMPORTED_MODULE_7__["c"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "defaultTheme", function() { return _Select_9fdb8cd0_browser_esm_js__WEBPACK_IMPORTED_MODULE_7__["a"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "mergeStyles", function() { return _Select_9fdb8cd0_browser_esm_js__WEBPACK_IMPORTED_MODULE_7__["m"]; });

/* harmony import */ var _emotion_css__WEBPACK_IMPORTED_MODULE_8__ = __webpack_require__(/*! @emotion/css */ "./node_modules/@emotion/css/dist/css.browser.esm.js");
/* harmony import */ var react_input_autosize__WEBPACK_IMPORTED_MODULE_9__ = __webpack_require__(/*! react-input-autosize */ "./node_modules/react-input-autosize/lib/AutosizeInput.js");
/* harmony import */ var react_input_autosize__WEBPACK_IMPORTED_MODULE_9___default = /*#__PURE__*/__webpack_require__.n(react_input_autosize__WEBPACK_IMPORTED_MODULE_9__);
/* harmony import */ var _stateManager_04f734a2_browser_esm_js__WEBPACK_IMPORTED_MODULE_10__ = __webpack_require__(/*! ./stateManager-04f734a2.browser.esm.js */ "./node_modules/react-select/dist/stateManager-04f734a2.browser.esm.js");
/* harmony import */ var _emotion_cache__WEBPACK_IMPORTED_MODULE_11__ = __webpack_require__(/*! @emotion/cache */ "./node_modules/@emotion/cache/dist/cache.browser.esm.js");














function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }

var NonceProvider =
/*#__PURE__*/
function (_Component) {
  _inheritsLoose(NonceProvider, _Component);

  function NonceProvider(props) {
    var _this;

    _this = _Component.call(this, props) || this;

    _this.createEmotionCache = function (nonce) {
      return Object(_emotion_cache__WEBPACK_IMPORTED_MODULE_11__["default"])({
        nonce: nonce
      });
    };

    _this.createEmotionCache = Object(memoize_one__WEBPACK_IMPORTED_MODULE_1__["default"])(_this.createEmotionCache);
    return _this;
  }

  var _proto = NonceProvider.prototype;

  _proto.render = function render() {
    var emotionCache = this.createEmotionCache(this.props.nonce);
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_emotion_core__WEBPACK_IMPORTED_MODULE_2__["CacheProvider"], {
      value: emotionCache
    }, this.props.children);
  };

  return NonceProvider;
}(react__WEBPACK_IMPORTED_MODULE_0__["Component"]);

var index = Object(_stateManager_04f734a2_browser_esm_js__WEBPACK_IMPORTED_MODULE_10__["m"])(_Select_9fdb8cd0_browser_esm_js__WEBPACK_IMPORTED_MODULE_7__["S"]);

/* harmony default export */ __webpack_exports__["default"] = (index);



/***/ }),

/***/ "./node_modules/react-select/dist/stateManager-04f734a2.browser.esm.js":
/*!*****************************************************************************!*\
  !*** ./node_modules/react-select/dist/stateManager-04f734a2.browser.esm.js ***!
  \*****************************************************************************/
/*! exports provided: m */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "m", function() { return manageState; });
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);


function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }
var defaultProps = {
  defaultInputValue: '',
  defaultMenuIsOpen: false,
  defaultValue: null
};

var manageState = function manageState(SelectComponent) {
  var _class, _temp;

  return _temp = _class =
  /*#__PURE__*/
  function (_Component) {
    _inheritsLoose(StateManager, _Component);

    function StateManager() {
      var _this;

      for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
        args[_key] = arguments[_key];
      }

      _this = _Component.call.apply(_Component, [this].concat(args)) || this;
      _this.select = void 0;
      _this.state = {
        inputValue: _this.props.inputValue !== undefined ? _this.props.inputValue : _this.props.defaultInputValue,
        menuIsOpen: _this.props.menuIsOpen !== undefined ? _this.props.menuIsOpen : _this.props.defaultMenuIsOpen,
        value: _this.props.value !== undefined ? _this.props.value : _this.props.defaultValue
      };

      _this.onChange = function (value, actionMeta) {
        _this.callProp('onChange', value, actionMeta);

        _this.setState({
          value: value
        });
      };

      _this.onInputChange = function (value, actionMeta) {
        // TODO: for backwards compatibility, we allow the prop to return a new
        // value, but now inputValue is a controllable prop we probably shouldn't
        var newValue = _this.callProp('onInputChange', value, actionMeta);

        _this.setState({
          inputValue: newValue !== undefined ? newValue : value
        });
      };

      _this.onMenuOpen = function () {
        _this.callProp('onMenuOpen');

        _this.setState({
          menuIsOpen: true
        });
      };

      _this.onMenuClose = function () {
        _this.callProp('onMenuClose');

        _this.setState({
          menuIsOpen: false
        });
      };

      return _this;
    }

    var _proto = StateManager.prototype;

    _proto.focus = function focus() {
      this.select.focus();
    };

    _proto.blur = function blur() {
      this.select.blur();
    } // FIXME: untyped flow code, return any
    ;

    _proto.getProp = function getProp(key) {
      return this.props[key] !== undefined ? this.props[key] : this.state[key];
    } // FIXME: untyped flow code, return any
    ;

    _proto.callProp = function callProp(name) {
      if (typeof this.props[name] === 'function') {
        var _this$props;

        for (var _len2 = arguments.length, args = new Array(_len2 > 1 ? _len2 - 1 : 0), _key2 = 1; _key2 < _len2; _key2++) {
          args[_key2 - 1] = arguments[_key2];
        }

        return (_this$props = this.props)[name].apply(_this$props, args);
      }
    };

    _proto.render = function render() {
      var _this2 = this;

      var _this$props2 = this.props,
          defaultInputValue = _this$props2.defaultInputValue,
          defaultMenuIsOpen = _this$props2.defaultMenuIsOpen,
          defaultValue = _this$props2.defaultValue,
          props = _objectWithoutPropertiesLoose(_this$props2, ["defaultInputValue", "defaultMenuIsOpen", "defaultValue"]);

      return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(SelectComponent, _extends({}, props, {
        ref: function ref(_ref) {
          _this2.select = _ref;
        },
        inputValue: this.getProp('inputValue'),
        menuIsOpen: this.getProp('menuIsOpen'),
        onChange: this.onChange,
        onInputChange: this.onInputChange,
        onMenuClose: this.onMenuClose,
        onMenuOpen: this.onMenuOpen,
        value: this.getProp('value')
      }));
    };

    return StateManager;
  }(react__WEBPACK_IMPORTED_MODULE_0__["Component"]), _class.defaultProps = defaultProps, _temp;
};




/***/ }),

/***/ "./node_modules/react-select/dist/utils-06b0d5a4.browser.esm.js":
/*!**********************************************************************!*\
  !*** ./node_modules/react-select/dist/utils-06b0d5a4.browser.esm.js ***!
  \**********************************************************************/
/*! exports provided: a, b, c, d, e, f, g, h, i, j, k, n, s */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return getScrollParent; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "b", function() { return getScrollTop; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "c", function() { return animatedScrollTo; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "d", function() { return isMobileDevice; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "e", function() { return cleanValue; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "f", function() { return scrollIntoView; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "g", function() { return getBoundingClientObj; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "h", function() { return classNames; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "i", function() { return isTouchCapable; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "j", function() { return isDocumentElement; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "k", function() { return handleInputChange; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "n", function() { return noop; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "s", function() { return scrollTo; });
// ==============================
// NO OP
// ==============================
var noop = function noop() {};
// Class Name Prefixer
// ==============================

/**
 String representation of component state for styling with class names.

 Expects an array of strings OR a string/object pair:
 - className(['comp', 'comp-arg', 'comp-arg-2'])
   @returns 'react-select__comp react-select__comp-arg react-select__comp-arg-2'
 - className('comp', { some: true, state: false })
   @returns 'react-select__comp react-select__comp--some'
*/

function applyPrefixToName(prefix, name) {
  if (!name) {
    return prefix;
  } else if (name[0] === '-') {
    return prefix + name;
  } else {
    return prefix + '__' + name;
  }
}

function classNames(prefix, state, className) {
  var arr = [className];

  if (state && prefix) {
    for (var key in state) {
      if (state.hasOwnProperty(key) && state[key]) {
        arr.push("" + applyPrefixToName(prefix, key));
      }
    }
  }

  return arr.filter(function (i) {
    return i;
  }).map(function (i) {
    return String(i).trim();
  }).join(' ');
} // ==============================
// Clean Value
// ==============================

var cleanValue = function cleanValue(value) {
  if (Array.isArray(value)) return value.filter(Boolean);
  if (typeof value === 'object' && value !== null) return [value];
  return [];
}; // ==============================
// Handle Input Change
// ==============================

function handleInputChange(inputValue, actionMeta, onInputChange) {
  if (onInputChange) {
    var newValue = onInputChange(inputValue, actionMeta);
    if (typeof newValue === 'string') return newValue;
  }

  return inputValue;
} // ==============================
// Scroll Helpers
// ==============================

function isDocumentElement(el) {
  return [document.documentElement, document.body, window].indexOf(el) > -1;
} // Normalized Scroll Top
// ------------------------------

function getScrollTop(el) {
  if (isDocumentElement(el)) {
    return window.pageYOffset;
  }

  return el.scrollTop;
}
function scrollTo(el, top) {
  // with a scroll distance, we perform scroll on the element
  if (isDocumentElement(el)) {
    window.scrollTo(0, top);
    return;
  }

  el.scrollTop = top;
} // Get Scroll Parent
// ------------------------------

function getScrollParent(element) {
  var style = getComputedStyle(element);
  var excludeStaticParent = style.position === 'absolute';
  var overflowRx = /(auto|scroll)/;
  var docEl = document.documentElement; // suck it, flow...

  if (style.position === 'fixed') return docEl;

  for (var parent = element; parent = parent.parentElement;) {
    style = getComputedStyle(parent);

    if (excludeStaticParent && style.position === 'static') {
      continue;
    }

    if (overflowRx.test(style.overflow + style.overflowY + style.overflowX)) {
      return parent;
    }
  }

  return docEl;
} // Animated Scroll To
// ------------------------------

/**
  @param t: time (elapsed)
  @param b: initial value
  @param c: amount of change
  @param d: duration
*/

function easeOutCubic(t, b, c, d) {
  return c * ((t = t / d - 1) * t * t + 1) + b;
}

function animatedScrollTo(element, to, duration, callback) {
  if (duration === void 0) {
    duration = 200;
  }

  if (callback === void 0) {
    callback = noop;
  }

  var start = getScrollTop(element);
  var change = to - start;
  var increment = 10;
  var currentTime = 0;

  function animateScroll() {
    currentTime += increment;
    var val = easeOutCubic(currentTime, start, change, duration);
    scrollTo(element, val);

    if (currentTime < duration) {
      window.requestAnimationFrame(animateScroll);
    } else {
      callback(element);
    }
  }

  animateScroll();
} // Scroll Into View
// ------------------------------

function scrollIntoView(menuEl, focusedEl) {
  var menuRect = menuEl.getBoundingClientRect();
  var focusedRect = focusedEl.getBoundingClientRect();
  var overScroll = focusedEl.offsetHeight / 3;

  if (focusedRect.bottom + overScroll > menuRect.bottom) {
    scrollTo(menuEl, Math.min(focusedEl.offsetTop + focusedEl.clientHeight - menuEl.offsetHeight + overScroll, menuEl.scrollHeight));
  } else if (focusedRect.top - overScroll < menuRect.top) {
    scrollTo(menuEl, Math.max(focusedEl.offsetTop - overScroll, 0));
  }
} // ==============================
// Get bounding client object
// ==============================
// cannot get keys using array notation with DOMRect

function getBoundingClientObj(element) {
  var rect = element.getBoundingClientRect();
  return {
    bottom: rect.bottom,
    height: rect.height,
    left: rect.left,
    right: rect.right,
    top: rect.top,
    width: rect.width
  };
}
// Touch Capability Detector
// ==============================

function isTouchCapable() {
  try {
    document.createEvent('TouchEvent');
    return true;
  } catch (e) {
    return false;
  }
} // ==============================
// Mobile Device Detector
// ==============================

function isMobileDevice() {
  try {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
  } catch (e) {
    return false;
  }
}




/***/ }),

/***/ "./node_modules/react-tabs/esm/components/Tab.js":
/*!*******************************************************!*\
  !*** ./node_modules/react-tabs/esm/components/Tab.js ***!
  \*******************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return Tab; });
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! prop-types */ "./node_modules/prop-types/index.js");
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(prop_types__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var classnames__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! classnames */ "./node_modules/classnames/index.js");
/* harmony import */ var classnames__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(classnames__WEBPACK_IMPORTED_MODULE_2__);
function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }




var DEFAULT_CLASS = 'react-tabs__tab';

var Tab =
/*#__PURE__*/
function (_Component) {
  _inheritsLoose(Tab, _Component);

  function Tab() {
    return _Component.apply(this, arguments) || this;
  }

  var _proto = Tab.prototype;

  _proto.componentDidMount = function componentDidMount() {
    this.checkFocus();
  };

  _proto.componentDidUpdate = function componentDidUpdate() {
    this.checkFocus();
  };

  _proto.checkFocus = function checkFocus() {
    var _this$props = this.props,
        selected = _this$props.selected,
        focus = _this$props.focus;

    if (selected && focus) {
      this.node.focus();
    }
  };

  _proto.render = function render() {
    var _cx,
        _this = this;

    var _this$props2 = this.props,
        children = _this$props2.children,
        className = _this$props2.className,
        disabled = _this$props2.disabled,
        disabledClassName = _this$props2.disabledClassName,
        focus = _this$props2.focus,
        id = _this$props2.id,
        panelId = _this$props2.panelId,
        selected = _this$props2.selected,
        selectedClassName = _this$props2.selectedClassName,
        tabIndex = _this$props2.tabIndex,
        tabRef = _this$props2.tabRef,
        attributes = _objectWithoutPropertiesLoose(_this$props2, ["children", "className", "disabled", "disabledClassName", "focus", "id", "panelId", "selected", "selectedClassName", "tabIndex", "tabRef"]);

    return react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement("li", _extends({}, attributes, {
      className: classnames__WEBPACK_IMPORTED_MODULE_2___default()(className, (_cx = {}, _cx[selectedClassName] = selected, _cx[disabledClassName] = disabled, _cx)),
      ref: function ref(node) {
        _this.node = node;
        if (tabRef) tabRef(node);
      },
      role: "tab",
      id: id,
      "aria-selected": selected ? 'true' : 'false',
      "aria-disabled": disabled ? 'true' : 'false',
      "aria-controls": panelId,
      tabIndex: tabIndex || (selected ? '0' : null)
    }), children);
  };

  return Tab;
}(react__WEBPACK_IMPORTED_MODULE_1__["Component"]);

Tab.defaultProps = {
  className: DEFAULT_CLASS,
  disabledClassName: DEFAULT_CLASS + "--disabled",
  focus: false,
  id: null,
  panelId: null,
  selected: false,
  selectedClassName: DEFAULT_CLASS + "--selected"
};

Tab.propTypes =  true ? {
  children: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.oneOfType([prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.array, prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.object, prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string]),
  className: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.oneOfType([prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string, prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.array, prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.object]),
  disabled: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.bool,
  tabIndex: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string,
  disabledClassName: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string,
  focus: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.bool,
  // private
  id: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string,
  // private
  panelId: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string,
  // private
  selected: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.bool,
  // private
  selectedClassName: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string,
  tabRef: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.func // private

} : undefined;
Tab.tabsRole = 'Tab';

/***/ }),

/***/ "./node_modules/react-tabs/esm/components/TabList.js":
/*!***********************************************************!*\
  !*** ./node_modules/react-tabs/esm/components/TabList.js ***!
  \***********************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return TabList; });
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! prop-types */ "./node_modules/prop-types/index.js");
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(prop_types__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var classnames__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! classnames */ "./node_modules/classnames/index.js");
/* harmony import */ var classnames__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(classnames__WEBPACK_IMPORTED_MODULE_2__);
function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }





var TabList =
/*#__PURE__*/
function (_Component) {
  _inheritsLoose(TabList, _Component);

  function TabList() {
    return _Component.apply(this, arguments) || this;
  }

  var _proto = TabList.prototype;

  _proto.render = function render() {
    var _this$props = this.props,
        children = _this$props.children,
        className = _this$props.className,
        attributes = _objectWithoutPropertiesLoose(_this$props, ["children", "className"]);

    return react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement("ul", _extends({}, attributes, {
      className: classnames__WEBPACK_IMPORTED_MODULE_2___default()(className),
      role: "tablist"
    }), children);
  };

  return TabList;
}(react__WEBPACK_IMPORTED_MODULE_1__["Component"]);

TabList.defaultProps = {
  className: 'react-tabs__tab-list'
};

TabList.propTypes =  true ? {
  children: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.oneOfType([prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.object, prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.array]),
  className: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.oneOfType([prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string, prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.array, prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.object])
} : undefined;
TabList.tabsRole = 'TabList';

/***/ }),

/***/ "./node_modules/react-tabs/esm/components/TabPanel.js":
/*!************************************************************!*\
  !*** ./node_modules/react-tabs/esm/components/TabPanel.js ***!
  \************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return TabPanel; });
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! prop-types */ "./node_modules/prop-types/index.js");
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(prop_types__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var classnames__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! classnames */ "./node_modules/classnames/index.js");
/* harmony import */ var classnames__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(classnames__WEBPACK_IMPORTED_MODULE_2__);
function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }




var DEFAULT_CLASS = 'react-tabs__tab-panel';

var TabPanel =
/*#__PURE__*/
function (_Component) {
  _inheritsLoose(TabPanel, _Component);

  function TabPanel() {
    return _Component.apply(this, arguments) || this;
  }

  var _proto = TabPanel.prototype;

  _proto.render = function render() {
    var _cx;

    var _this$props = this.props,
        children = _this$props.children,
        className = _this$props.className,
        forceRender = _this$props.forceRender,
        id = _this$props.id,
        selected = _this$props.selected,
        selectedClassName = _this$props.selectedClassName,
        tabId = _this$props.tabId,
        attributes = _objectWithoutPropertiesLoose(_this$props, ["children", "className", "forceRender", "id", "selected", "selectedClassName", "tabId"]);

    return react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement("div", _extends({}, attributes, {
      className: classnames__WEBPACK_IMPORTED_MODULE_2___default()(className, (_cx = {}, _cx[selectedClassName] = selected, _cx)),
      role: "tabpanel",
      id: id,
      "aria-labelledby": tabId
    }), forceRender || selected ? children : null);
  };

  return TabPanel;
}(react__WEBPACK_IMPORTED_MODULE_1__["Component"]);

TabPanel.defaultProps = {
  className: DEFAULT_CLASS,
  forceRender: false,
  selectedClassName: DEFAULT_CLASS + "--selected"
};

TabPanel.propTypes =  true ? {
  children: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.node,
  className: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.oneOfType([prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string, prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.array, prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.object]),
  forceRender: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.bool,
  id: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string,
  // private
  selected: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.bool,
  // private
  selectedClassName: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string,
  tabId: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string // private

} : undefined;
TabPanel.tabsRole = 'TabPanel';

/***/ }),

/***/ "./node_modules/react-tabs/esm/components/Tabs.js":
/*!********************************************************!*\
  !*** ./node_modules/react-tabs/esm/components/Tabs.js ***!
  \********************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return Tabs; });
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! prop-types */ "./node_modules/prop-types/index.js");
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(prop_types__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _helpers_propTypes__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../helpers/propTypes */ "./node_modules/react-tabs/esm/helpers/propTypes.js");
/* harmony import */ var _UncontrolledTabs__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./UncontrolledTabs */ "./node_modules/react-tabs/esm/components/UncontrolledTabs.js");
/* harmony import */ var _helpers_count__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ../helpers/count */ "./node_modules/react-tabs/esm/helpers/count.js");
function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }






var MODE_CONTROLLED = 0;
var MODE_UNCONTROLLED = 1;

var Tabs =
/*#__PURE__*/
function (_Component) {
  _inheritsLoose(Tabs, _Component);

  function Tabs(props) {
    var _this;

    _this = _Component.call(this, props) || this;

    _this.handleSelected = function (index, last, event) {
      var onSelect = _this.props.onSelect;
      var mode = _this.state.mode; // Call change event handler

      if (typeof onSelect === 'function') {
        // Check if the change event handler cancels the tab change
        if (onSelect(index, last, event) === false) return;
      }

      var state = {
        // Set focus if the change was triggered from the keyboard
        focus: event.type === 'keydown'
      };

      if (mode === MODE_UNCONTROLLED) {
        // Update selected index
        state.selectedIndex = index;
      }

      _this.setState(state);
    };

    _this.state = Tabs.copyPropsToState(_this.props, {}, props.defaultFocus);
    return _this;
  }

  Tabs.getDerivedStateFromProps = function getDerivedStateFromProps(props, state) {
    return Tabs.copyPropsToState(props, state);
  };

  Tabs.getModeFromProps = function getModeFromProps(props) {
    return props.selectedIndex === null ? MODE_UNCONTROLLED : MODE_CONTROLLED;
  };

  // preserve the existing selectedIndex from state.
  // If the state has not selectedIndex, default to the defaultIndex or 0
  Tabs.copyPropsToState = function copyPropsToState(props, state, focus) {
    if (focus === void 0) {
      focus = false;
    }

    if ( true && state.mode !== undefined && state.mode !== Tabs.getModeFromProps(props)) {
      throw new Error("Switching between controlled mode (by using `selectedIndex`) and uncontrolled mode is not supported in `Tabs`.\nFor more information about controlled and uncontrolled mode of react-tabs see the README.");
    }

    var newState = {
      focus: focus,
      mode: Tabs.getModeFromProps(props)
    };

    if (newState.mode === MODE_UNCONTROLLED) {
      var maxTabIndex = Object(_helpers_count__WEBPACK_IMPORTED_MODULE_4__["getTabsCount"])(props.children) - 1;
      var selectedIndex = null;

      if (state.selectedIndex != null) {
        selectedIndex = Math.min(state.selectedIndex, maxTabIndex);
      } else {
        selectedIndex = props.defaultIndex || 0;
      }

      newState.selectedIndex = selectedIndex;
    }

    return newState;
  };

  var _proto = Tabs.prototype;

  _proto.render = function render() {
    var _this$props = this.props,
        children = _this$props.children,
        defaultIndex = _this$props.defaultIndex,
        defaultFocus = _this$props.defaultFocus,
        props = _objectWithoutPropertiesLoose(_this$props, ["children", "defaultIndex", "defaultFocus"]);

    var _this$state = this.state,
        focus = _this$state.focus,
        selectedIndex = _this$state.selectedIndex;
    props.focus = focus;
    props.onSelect = this.handleSelected;

    if (selectedIndex != null) {
      props.selectedIndex = selectedIndex;
    }

    return react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_UncontrolledTabs__WEBPACK_IMPORTED_MODULE_3__["default"], props, children);
  };

  return Tabs;
}(react__WEBPACK_IMPORTED_MODULE_1__["Component"]);

Tabs.defaultProps = {
  defaultFocus: false,
  forceRenderTabPanel: false,
  selectedIndex: null,
  defaultIndex: null
};

Tabs.propTypes =  true ? {
  children: _helpers_propTypes__WEBPACK_IMPORTED_MODULE_2__["childrenPropType"],
  direction: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.oneOf(['rtl', 'ltr']),
  className: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.oneOfType([prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string, prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.array, prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.object]),
  defaultFocus: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.bool,
  defaultIndex: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.number,
  disabledTabClassName: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string,
  domRef: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.func,
  forceRenderTabPanel: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.bool,
  onSelect: _helpers_propTypes__WEBPACK_IMPORTED_MODULE_2__["onSelectPropType"],
  selectedIndex: _helpers_propTypes__WEBPACK_IMPORTED_MODULE_2__["selectedIndexPropType"],
  selectedTabClassName: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string,
  selectedTabPanelClassName: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string
} : undefined;
Tabs.tabsRole = 'Tabs';

/***/ }),

/***/ "./node_modules/react-tabs/esm/components/UncontrolledTabs.js":
/*!********************************************************************!*\
  !*** ./node_modules/react-tabs/esm/components/UncontrolledTabs.js ***!
  \********************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return UncontrolledTabs; });
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! prop-types */ "./node_modules/prop-types/index.js");
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(prop_types__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var classnames__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! classnames */ "./node_modules/classnames/index.js");
/* harmony import */ var classnames__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(classnames__WEBPACK_IMPORTED_MODULE_2__);
/* harmony import */ var _helpers_uuid__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ../helpers/uuid */ "./node_modules/react-tabs/esm/helpers/uuid.js");
/* harmony import */ var _helpers_propTypes__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ../helpers/propTypes */ "./node_modules/react-tabs/esm/helpers/propTypes.js");
/* harmony import */ var _helpers_count__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ../helpers/count */ "./node_modules/react-tabs/esm/helpers/count.js");
/* harmony import */ var _helpers_childrenDeepMap__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! ../helpers/childrenDeepMap */ "./node_modules/react-tabs/esm/helpers/childrenDeepMap.js");
/* harmony import */ var _helpers_elementTypes__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! ../helpers/elementTypes */ "./node_modules/react-tabs/esm/helpers/elementTypes.js");
function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }










function isNode(node) {
  return node && 'getAttribute' in node;
} // Determine if a node from event.target is a Tab element


function isTabNode(node) {
  return isNode(node) && node.getAttribute('role') === 'tab';
} // Determine if a tab node is disabled


function isTabDisabled(node) {
  return isNode(node) && node.getAttribute('aria-disabled') === 'true';
}

var canUseActiveElement;

try {
  canUseActiveElement = !!(typeof window !== 'undefined' && window.document && window.document.activeElement);
} catch (e) {
  // Work around for IE bug when accessing document.activeElement in an iframe
  // Refer to the following resources:
  // http://stackoverflow.com/a/10982960/369687
  // https://developer.microsoft.com/en-us/microsoft-edge/platform/issues/12733599
  canUseActiveElement = false;
}

var UncontrolledTabs =
/*#__PURE__*/
function (_Component) {
  _inheritsLoose(UncontrolledTabs, _Component);

  function UncontrolledTabs() {
    var _this;

    for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
      args[_key] = arguments[_key];
    }

    _this = _Component.call.apply(_Component, [this].concat(args)) || this;
    _this.tabNodes = [];

    _this.handleKeyDown = function (e) {
      var direction = _this.props.direction;

      if (_this.isTabFromContainer(e.target)) {
        var index = _this.props.selectedIndex;
        var preventDefault = false;
        var useSelectedIndex = false;

        if (e.keyCode === 32 || e.keyCode === 13) {
          preventDefault = true;
          useSelectedIndex = false;

          _this.handleClick(e);
        }

        if (e.keyCode === 37 || e.keyCode === 38) {
          // Select next tab to the left
          if (direction === 'rtl') {
            index = _this.getNextTab(index);
          } else {
            index = _this.getPrevTab(index);
          }

          preventDefault = true;
          useSelectedIndex = true;
        } else if (e.keyCode === 39 || e.keyCode === 40) {
          // Select next tab to the right
          if (direction === 'rtl') {
            index = _this.getPrevTab(index);
          } else {
            index = _this.getNextTab(index);
          }

          preventDefault = true;
          useSelectedIndex = true;
        } else if (e.keyCode === 35) {
          // Select last tab (End key)
          index = _this.getLastTab();
          preventDefault = true;
          useSelectedIndex = true;
        } else if (e.keyCode === 36) {
          // Select first tab (Home key)
          index = _this.getFirstTab();
          preventDefault = true;
          useSelectedIndex = true;
        } // This prevents scrollbars from moving around


        if (preventDefault) {
          e.preventDefault();
        } // Only use the selected index in the state if we're not using the tabbed index


        if (useSelectedIndex) {
          _this.setSelected(index, e);
        }
      }
    };

    _this.handleClick = function (e) {
      var node = e.target;

      do {
        if (_this.isTabFromContainer(node)) {
          if (isTabDisabled(node)) {
            return;
          }

          var index = [].slice.call(node.parentNode.children).filter(isTabNode).indexOf(node);

          _this.setSelected(index, e);

          return;
        } // eslint-disable-next-line no-cond-assign

      } while ((node = node.parentNode) != null);
    };

    return _this;
  }

  var _proto = UncontrolledTabs.prototype;

  _proto.setSelected = function setSelected(index, event) {
    // Check index boundary
    if (index < 0 || index >= this.getTabsCount()) return;
    var _this$props = this.props,
        onSelect = _this$props.onSelect,
        selectedIndex = _this$props.selectedIndex; // Call change event handler

    onSelect(index, selectedIndex, event);
  };

  _proto.getNextTab = function getNextTab(index) {
    var count = this.getTabsCount(); // Look for non-disabled tab from index to the last tab on the right

    for (var i = index + 1; i < count; i++) {
      if (!isTabDisabled(this.getTab(i))) {
        return i;
      }
    } // If no tab found, continue searching from first on left to index


    for (var _i = 0; _i < index; _i++) {
      if (!isTabDisabled(this.getTab(_i))) {
        return _i;
      }
    } // No tabs are disabled, return index


    return index;
  };

  _proto.getPrevTab = function getPrevTab(index) {
    var i = index; // Look for non-disabled tab from index to first tab on the left

    while (i--) {
      if (!isTabDisabled(this.getTab(i))) {
        return i;
      }
    } // If no tab found, continue searching from last tab on right to index


    i = this.getTabsCount();

    while (i-- > index) {
      if (!isTabDisabled(this.getTab(i))) {
        return i;
      }
    } // No tabs are disabled, return index


    return index;
  };

  _proto.getFirstTab = function getFirstTab() {
    var count = this.getTabsCount(); // Look for non disabled tab from the first tab

    for (var i = 0; i < count; i++) {
      if (!isTabDisabled(this.getTab(i))) {
        return i;
      }
    }

    return null;
  };

  _proto.getLastTab = function getLastTab() {
    var i = this.getTabsCount(); // Look for non disabled tab from the last tab

    while (i--) {
      if (!isTabDisabled(this.getTab(i))) {
        return i;
      }
    }

    return null;
  };

  _proto.getTabsCount = function getTabsCount() {
    var children = this.props.children;
    return Object(_helpers_count__WEBPACK_IMPORTED_MODULE_5__["getTabsCount"])(children);
  };

  _proto.getPanelsCount = function getPanelsCount() {
    var children = this.props.children;
    return Object(_helpers_count__WEBPACK_IMPORTED_MODULE_5__["getPanelsCount"])(children);
  };

  _proto.getTab = function getTab(index) {
    return this.tabNodes["tabs-" + index];
  };

  _proto.getChildren = function getChildren() {
    var _this2 = this;

    var index = 0;
    var _this$props2 = this.props,
        children = _this$props2.children,
        disabledTabClassName = _this$props2.disabledTabClassName,
        focus = _this$props2.focus,
        forceRenderTabPanel = _this$props2.forceRenderTabPanel,
        selectedIndex = _this$props2.selectedIndex,
        selectedTabClassName = _this$props2.selectedTabClassName,
        selectedTabPanelClassName = _this$props2.selectedTabPanelClassName;
    this.tabIds = this.tabIds || [];
    this.panelIds = this.panelIds || [];
    var diff = this.tabIds.length - this.getTabsCount(); // Add ids if new tabs have been added
    // Don't bother removing ids, just keep them in case they are added again
    // This is more efficient, and keeps the uuid counter under control

    while (diff++ < 0) {
      this.tabIds.push(Object(_helpers_uuid__WEBPACK_IMPORTED_MODULE_3__["default"])());
      this.panelIds.push(Object(_helpers_uuid__WEBPACK_IMPORTED_MODULE_3__["default"])());
    } // Map children to dynamically setup refs


    return Object(_helpers_childrenDeepMap__WEBPACK_IMPORTED_MODULE_6__["deepMap"])(children, function (child) {
      var result = child; // Clone TabList and Tab components to have refs

      if (Object(_helpers_elementTypes__WEBPACK_IMPORTED_MODULE_7__["isTabList"])(child)) {
        var listIndex = 0; // Figure out if the current focus in the DOM is set on a Tab
        // If it is we should keep the focus on the next selected tab

        var wasTabFocused = false;

        if (canUseActiveElement) {
          wasTabFocused = react__WEBPACK_IMPORTED_MODULE_1___default.a.Children.toArray(child.props.children).filter(_helpers_elementTypes__WEBPACK_IMPORTED_MODULE_7__["isTab"]).some(function (tab, i) {
            return document.activeElement === _this2.getTab(i);
          });
        }

        result = Object(react__WEBPACK_IMPORTED_MODULE_1__["cloneElement"])(child, {
          children: Object(_helpers_childrenDeepMap__WEBPACK_IMPORTED_MODULE_6__["deepMap"])(child.props.children, function (tab) {
            var key = "tabs-" + listIndex;
            var selected = selectedIndex === listIndex;
            var props = {
              tabRef: function tabRef(node) {
                _this2.tabNodes[key] = node;
              },
              id: _this2.tabIds[listIndex],
              panelId: _this2.panelIds[listIndex],
              selected: selected,
              focus: selected && (focus || wasTabFocused)
            };
            if (selectedTabClassName) props.selectedClassName = selectedTabClassName;
            if (disabledTabClassName) props.disabledClassName = disabledTabClassName;
            listIndex++;
            return Object(react__WEBPACK_IMPORTED_MODULE_1__["cloneElement"])(tab, props);
          })
        });
      } else if (Object(_helpers_elementTypes__WEBPACK_IMPORTED_MODULE_7__["isTabPanel"])(child)) {
        var props = {
          id: _this2.panelIds[index],
          tabId: _this2.tabIds[index],
          selected: selectedIndex === index
        };
        if (forceRenderTabPanel) props.forceRender = forceRenderTabPanel;
        if (selectedTabPanelClassName) props.selectedClassName = selectedTabPanelClassName;
        index++;
        result = Object(react__WEBPACK_IMPORTED_MODULE_1__["cloneElement"])(child, props);
      }

      return result;
    });
  };

  /**
   * Determine if a node from event.target is a Tab element for the current Tabs container.
   * If the clicked element is not a Tab, it returns false.
   * If it finds another Tabs container between the Tab and `this`, it returns false.
   */
  _proto.isTabFromContainer = function isTabFromContainer(node) {
    // return immediately if the clicked element is not a Tab.
    if (!isTabNode(node)) {
      return false;
    } // Check if the first occurrence of a Tabs container is `this` one.


    var nodeAncestor = node.parentElement;

    do {
      if (nodeAncestor === this.node) return true;
      if (nodeAncestor.getAttribute('data-tabs')) break;
      nodeAncestor = nodeAncestor.parentElement;
    } while (nodeAncestor);

    return false;
  };

  _proto.render = function render() {
    var _this3 = this;

    // Delete all known props, so they don't get added to DOM
    var _this$props3 = this.props,
        children = _this$props3.children,
        className = _this$props3.className,
        disabledTabClassName = _this$props3.disabledTabClassName,
        domRef = _this$props3.domRef,
        focus = _this$props3.focus,
        forceRenderTabPanel = _this$props3.forceRenderTabPanel,
        onSelect = _this$props3.onSelect,
        selectedIndex = _this$props3.selectedIndex,
        selectedTabClassName = _this$props3.selectedTabClassName,
        selectedTabPanelClassName = _this$props3.selectedTabPanelClassName,
        attributes = _objectWithoutPropertiesLoose(_this$props3, ["children", "className", "disabledTabClassName", "domRef", "focus", "forceRenderTabPanel", "onSelect", "selectedIndex", "selectedTabClassName", "selectedTabPanelClassName"]);

    return react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement("div", _extends({}, attributes, {
      className: classnames__WEBPACK_IMPORTED_MODULE_2___default()(className),
      onClick: this.handleClick,
      onKeyDown: this.handleKeyDown,
      ref: function ref(node) {
        _this3.node = node;
        if (domRef) domRef(node);
      },
      "data-tabs": true
    }), this.getChildren());
  };

  return UncontrolledTabs;
}(react__WEBPACK_IMPORTED_MODULE_1__["Component"]);

UncontrolledTabs.defaultProps = {
  className: 'react-tabs',
  focus: false
};

UncontrolledTabs.propTypes =  true ? {
  children: _helpers_propTypes__WEBPACK_IMPORTED_MODULE_4__["childrenPropType"],
  direction: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.oneOf(['rtl', 'ltr']),
  className: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.oneOfType([prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string, prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.array, prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.object]),
  disabledTabClassName: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string,
  domRef: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.func,
  focus: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.bool,
  forceRenderTabPanel: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.bool,
  onSelect: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.func.isRequired,
  selectedIndex: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.number.isRequired,
  selectedTabClassName: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string,
  selectedTabPanelClassName: prop_types__WEBPACK_IMPORTED_MODULE_0___default.a.string
} : undefined;

/***/ }),

/***/ "./node_modules/react-tabs/esm/helpers/childrenDeepMap.js":
/*!****************************************************************!*\
  !*** ./node_modules/react-tabs/esm/helpers/childrenDeepMap.js ***!
  \****************************************************************/
/*! exports provided: deepMap, deepForEach */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "deepMap", function() { return deepMap; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "deepForEach", function() { return deepForEach; });
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _elementTypes__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./elementTypes */ "./node_modules/react-tabs/esm/helpers/elementTypes.js");
function ownKeys(object, enumerableOnly) { var keys = Object.keys(object); if (Object.getOwnPropertySymbols) { var symbols = Object.getOwnPropertySymbols(object); if (enumerableOnly) symbols = symbols.filter(function (sym) { return Object.getOwnPropertyDescriptor(object, sym).enumerable; }); keys.push.apply(keys, symbols); } return keys; }

function _objectSpread(target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i] != null ? arguments[i] : {}; if (i % 2) { ownKeys(Object(source), true).forEach(function (key) { _defineProperty(target, key, source[key]); }); } else if (Object.getOwnPropertyDescriptors) { Object.defineProperties(target, Object.getOwnPropertyDescriptors(source)); } else { ownKeys(Object(source)).forEach(function (key) { Object.defineProperty(target, key, Object.getOwnPropertyDescriptor(source, key)); }); } } return target; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }




function isTabChild(child) {
  return Object(_elementTypes__WEBPACK_IMPORTED_MODULE_1__["isTab"])(child) || Object(_elementTypes__WEBPACK_IMPORTED_MODULE_1__["isTabList"])(child) || Object(_elementTypes__WEBPACK_IMPORTED_MODULE_1__["isTabPanel"])(child);
}

function deepMap(children, callback) {
  return react__WEBPACK_IMPORTED_MODULE_0__["Children"].map(children, function (child) {
    // null happens when conditionally rendering TabPanel/Tab
    // see https://github.com/reactjs/react-tabs/issues/37
    if (child === null) return null;

    if (isTabChild(child)) {
      return callback(child);
    }

    if (child.props && child.props.children && typeof child.props.children === 'object') {
      // Clone the child that has children and map them too
      return Object(react__WEBPACK_IMPORTED_MODULE_0__["cloneElement"])(child, _objectSpread({}, child.props, {
        children: deepMap(child.props.children, callback)
      }));
    }

    return child;
  });
}
function deepForEach(children, callback) {
  return react__WEBPACK_IMPORTED_MODULE_0__["Children"].forEach(children, function (child) {
    // null happens when conditionally rendering TabPanel/Tab
    // see https://github.com/reactjs/react-tabs/issues/37
    if (child === null) return;

    if (Object(_elementTypes__WEBPACK_IMPORTED_MODULE_1__["isTab"])(child) || Object(_elementTypes__WEBPACK_IMPORTED_MODULE_1__["isTabPanel"])(child)) {
      callback(child);
    } else if (child.props && child.props.children && typeof child.props.children === 'object') {
      if (Object(_elementTypes__WEBPACK_IMPORTED_MODULE_1__["isTabList"])(child)) callback(child);
      deepForEach(child.props.children, callback);
    }
  });
}

/***/ }),

/***/ "./node_modules/react-tabs/esm/helpers/count.js":
/*!******************************************************!*\
  !*** ./node_modules/react-tabs/esm/helpers/count.js ***!
  \******************************************************/
/*! exports provided: getTabsCount, getPanelsCount */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getTabsCount", function() { return getTabsCount; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getPanelsCount", function() { return getPanelsCount; });
/* harmony import */ var _childrenDeepMap__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./childrenDeepMap */ "./node_modules/react-tabs/esm/helpers/childrenDeepMap.js");
/* harmony import */ var _elementTypes__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./elementTypes */ "./node_modules/react-tabs/esm/helpers/elementTypes.js");


function getTabsCount(children) {
  var tabCount = 0;
  Object(_childrenDeepMap__WEBPACK_IMPORTED_MODULE_0__["deepForEach"])(children, function (child) {
    if (Object(_elementTypes__WEBPACK_IMPORTED_MODULE_1__["isTab"])(child)) tabCount++;
  });
  return tabCount;
}
function getPanelsCount(children) {
  var panelCount = 0;
  Object(_childrenDeepMap__WEBPACK_IMPORTED_MODULE_0__["deepForEach"])(children, function (child) {
    if (Object(_elementTypes__WEBPACK_IMPORTED_MODULE_1__["isTabPanel"])(child)) panelCount++;
  });
  return panelCount;
}

/***/ }),

/***/ "./node_modules/react-tabs/esm/helpers/elementTypes.js":
/*!*************************************************************!*\
  !*** ./node_modules/react-tabs/esm/helpers/elementTypes.js ***!
  \*************************************************************/
/*! exports provided: isTab, isTabList, isTabPanel */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isTab", function() { return isTab; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isTabList", function() { return isTabList; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isTabPanel", function() { return isTabPanel; });
function makeTypeChecker(tabsRole) {
  return function (element) {
    return !!element.type && element.type.tabsRole === tabsRole;
  };
}

var isTab = makeTypeChecker('Tab');
var isTabList = makeTypeChecker('TabList');
var isTabPanel = makeTypeChecker('TabPanel');

/***/ }),

/***/ "./node_modules/react-tabs/esm/helpers/propTypes.js":
/*!**********************************************************!*\
  !*** ./node_modules/react-tabs/esm/helpers/propTypes.js ***!
  \**********************************************************/
/*! exports provided: childrenPropType, onSelectPropType, selectedIndexPropType */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "childrenPropType", function() { return childrenPropType; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "onSelectPropType", function() { return onSelectPropType; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "selectedIndexPropType", function() { return selectedIndexPropType; });
/* harmony import */ var _childrenDeepMap__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./childrenDeepMap */ "./node_modules/react-tabs/esm/helpers/childrenDeepMap.js");
/* harmony import */ var _elementTypes__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./elementTypes */ "./node_modules/react-tabs/esm/helpers/elementTypes.js");


function childrenPropType(props, propName, componentName) {
  var error;
  var tabsCount = 0;
  var panelsCount = 0;
  var tabListFound = false;
  var listTabs = [];
  var children = props[propName];
  Object(_childrenDeepMap__WEBPACK_IMPORTED_MODULE_0__["deepForEach"])(children, function (child) {
    if (Object(_elementTypes__WEBPACK_IMPORTED_MODULE_1__["isTabList"])(child)) {
      if (child.props && child.props.children && typeof child.props.children === 'object') {
        Object(_childrenDeepMap__WEBPACK_IMPORTED_MODULE_0__["deepForEach"])(child.props.children, function (listChild) {
          return listTabs.push(listChild);
        });
      }

      if (tabListFound) {
        error = new Error("Found multiple 'TabList' components inside 'Tabs'. Only one is allowed.");
      }

      tabListFound = true;
    }

    if (Object(_elementTypes__WEBPACK_IMPORTED_MODULE_1__["isTab"])(child)) {
      if (!tabListFound || listTabs.indexOf(child) === -1) {
        error = new Error("Found a 'Tab' component outside of the 'TabList' component. 'Tab' components " + "have to be inside the 'TabList' component.");
      }

      tabsCount++;
    } else if (Object(_elementTypes__WEBPACK_IMPORTED_MODULE_1__["isTabPanel"])(child)) {
      panelsCount++;
    }
  });

  if (!error && tabsCount !== panelsCount) {
    error = new Error("There should be an equal number of 'Tab' and 'TabPanel' in `" + componentName + "`. " + ("Received " + tabsCount + " 'Tab' and " + panelsCount + " 'TabPanel'."));
  }

  return error;
}
function onSelectPropType(props, propName, componentName, location, propFullName) {
  var prop = props[propName];
  var name = propFullName || propName;
  var error = null;

  if (prop && typeof prop !== 'function') {
    error = new Error("Invalid " + location + " `" + name + "` of type `" + typeof prop + "` supplied " + ("to `" + componentName + "`, expected `function`."));
  } else if (props.selectedIndex != null && prop == null) {
    error = new Error("The " + location + " `" + name + "` is marked as required in `" + componentName + "`, but " + "its value is `undefined` or `null`.\n" + "`onSelect` is required when `selectedIndex` is also set. Not doing so will " + "make the tabs not do anything, as `selectedIndex` indicates that you want to " + "handle the selected tab yourself.\n" + "If you only want to set the inital tab replace `selectedIndex` with `defaultIndex`.");
  }

  return error;
}
function selectedIndexPropType(props, propName, componentName, location, propFullName) {
  var prop = props[propName];
  var name = propFullName || propName;
  var error = null;

  if (prop != null && typeof prop !== 'number') {
    error = new Error("Invalid " + location + " `" + name + "` of type `" + typeof prop + "` supplied to " + ("`" + componentName + "`, expected `number`."));
  } else if (props.defaultIndex != null && prop != null) {
    return new Error("The " + location + " `" + name + "` cannot be used together with `defaultIndex` " + ("in `" + componentName + "`.\n") + ("Either remove `" + name + "` to let `" + componentName + "` handle the selected ") + "tab internally or remove `defaultIndex` to handle it yourself.");
  }

  return error;
}

/***/ }),

/***/ "./node_modules/react-tabs/esm/helpers/uuid.js":
/*!*****************************************************!*\
  !*** ./node_modules/react-tabs/esm/helpers/uuid.js ***!
  \*****************************************************/
/*! exports provided: default, reset */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return uuid; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "reset", function() { return reset; });
// Get a universally unique identifier
var count = 0;
function uuid() {
  return "react-tabs-" + count++;
}
function reset() {
  count = 0;
}

/***/ }),

/***/ "./node_modules/react-tabs/esm/index.js":
/*!**********************************************!*\
  !*** ./node_modules/react-tabs/esm/index.js ***!
  \**********************************************/
/*! exports provided: Tabs, TabList, Tab, TabPanel, resetIdCounter */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _components_Tabs__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./components/Tabs */ "./node_modules/react-tabs/esm/components/Tabs.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Tabs", function() { return _components_Tabs__WEBPACK_IMPORTED_MODULE_0__["default"]; });

/* harmony import */ var _components_TabList__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./components/TabList */ "./node_modules/react-tabs/esm/components/TabList.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "TabList", function() { return _components_TabList__WEBPACK_IMPORTED_MODULE_1__["default"]; });

/* harmony import */ var _components_Tab__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./components/Tab */ "./node_modules/react-tabs/esm/components/Tab.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Tab", function() { return _components_Tab__WEBPACK_IMPORTED_MODULE_2__["default"]; });

/* harmony import */ var _components_TabPanel__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./components/TabPanel */ "./node_modules/react-tabs/esm/components/TabPanel.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "TabPanel", function() { return _components_TabPanel__WEBPACK_IMPORTED_MODULE_3__["default"]; });

/* harmony import */ var _helpers_uuid__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./helpers/uuid */ "./node_modules/react-tabs/esm/helpers/uuid.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "resetIdCounter", function() { return _helpers_uuid__WEBPACK_IMPORTED_MODULE_4__["reset"]; });







/***/ }),

/***/ "./node_modules/react-tabs/style/react-tabs.css":
/*!******************************************************!*\
  !*** ./node_modules/react-tabs/style/react-tabs.css ***!
  \******************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

// extracted by mini-css-extract-plugin

/***/ }),

/***/ "./src/page-item-authoring/common/components/aspect-ratio-chooser.tsx":
/*!****************************************************************************!*\
  !*** ./src/page-item-authoring/common/components/aspect-ratio-chooser.tsx ***!
  \****************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var React = __webpack_require__(/*! react */ "react");
var react_1 = __webpack_require__(/*! react */ "react");
exports.availableAspectRatios = {
    DEFAULT: "Default aspect ratio, or set by interactive",
    MANUAL: "Manually set the native width & height",
    MAX: "Use all available space for the interactive"
};
var FormattedField = function (_a) {
    var value = _a.value, label = _a.label, onChange = _a.onChange;
    return (React.createElement("div", { style: { display: "flex", flexDirection: "row", alignItems: "baseline" } },
        React.createElement("label", { style: { textAlign: "right", padding: "0 5px" } }, label),
        React.createElement("input", { style: { width: 50, padding: 5 }, type: "number", value: value, onChange: onChange })));
};
exports.AspectRatioChooser = function (props) {
    var _a = react_1.useState(props.width), width = _a[0], setWidth = _a[1];
    var _b = react_1.useState(props.height), height = _b[0], setHeight = _b[1];
    var _c = react_1.useState(props.mode), mode = _c[0], setMode = _c[1];
    var handleSelectChange = function (e) {
        var newMode = e.target.value;
        setMode(newMode);
        props.onChange({ width: width, height: height, mode: newMode });
    };
    var handleChangeWidth = function (e) {
        var newWidth = parseInt(e.target.value, 10);
        setWidth(newWidth);
        props.onChange({ width: newWidth, height: height, mode: mode });
    };
    var handleChangeHeight = function (e) {
        var newHeight = parseInt(e.target.value, 10);
        setHeight(newHeight);
        props.onChange({ width: width, height: newHeight, mode: mode });
    };
    var renderInputs = function () {
        var inputStyle = {
            display: "flex",
            flexDirection: "row",
            flexWrap: "wrap",
            marginRight: "0.5em",
        };
        return (React.createElement("div", { style: inputStyle },
            React.createElement(FormattedField, { value: width, label: "Width", onChange: handleChangeWidth }),
            React.createElement(FormattedField, { value: height, label: "Height", onChange: handleChangeHeight })));
    };
    return (React.createElement("div", { style: { display: "flex", flexDirection: "row", padding: "0.5em", alignItems: "baseline" } },
        React.createElement("select", { style: { margin: "0.2em" }, onChange: handleSelectChange }, Object.keys(exports.availableAspectRatios).map(function (key) {
            var value = exports.availableAspectRatios[key];
            return React.createElement("option", { key: key, value: key, label: value, selected: key === mode }, value);
        })),
        mode === "MANUAL" ? renderInputs() : undefined));
};


/***/ }),

/***/ "./src/page-item-authoring/common/components/interactive-authoring.tsx":
/*!*****************************************************************************!*\
  !*** ./src/page-item-authoring/common/components/interactive-authoring.tsx ***!
  \*****************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var React = __webpack_require__(/*! react */ "react");
var react_1 = __webpack_require__(/*! react */ "react");
var interactive_iframe_1 = __webpack_require__(/*! ./interactive-iframe */ "./src/page-item-authoring/common/components/interactive-iframe.tsx");
exports.InteractiveAuthoring = function (_a) {
    var interactive = _a.interactive, onAuthoredStateChange = _a.onAuthoredStateChange, allowReset = _a.allowReset;
    var iframe = react_1.useRef(null);
    var _b = react_1.useState(false), authoringSupported = _b[0], setAuthoringSupported = _b[1];
    var _c = react_1.useState(typeof interactive.authored_state === "string"
        ? JSON.parse(interactive.authored_state || "{}")
        : interactive.authored_state), authoredState = _c[0], setAuthoredState = _c[1];
    var _d = react_1.useState(0), resetCount = _d[0], setResetCount = _d[1];
    var handleAuthoredStateChange = function (newAuthoredState) {
        setAuthoredState(newAuthoredState);
        onAuthoredStateChange(newAuthoredState);
    };
    var handleHeightChange = function (newHeight) {
        if (iframe.current) {
            iframe.current.style.height = newHeight + "px";
        }
    };
    var handleSupportedFeatures = function (info) {
        setAuthoringSupported(!!info.features.authoredState);
        if (info.features.aspectRatio) {
            if (interactive.aspect_ratio_method === "DEFAULT") {
                if (iframe.current) {
                    iframe.current.style.height = Math.round(iframe.current.offsetWidth / info.features.aspectRatio) + "px";
                }
            }
        }
    };
    var handleReset = function () {
        setAuthoredState(null);
        setResetCount(resetCount + 1);
    };
    var handleSetIframeRef = function (current) { return iframe.current = current; };
    var initMsg = {
        version: 1,
        error: null,
        mode: "authoring",
        authoredState: authoredState
    };
    return (React.createElement("div", { className: "authoring-mw-interactive" },
        allowReset
            ? React.createElement("div", { className: "status " + (authoringSupported ? "visible" : "") }, authoredState
                ? React.createElement("input", { type: "button", className: "reset-btn", value: "Reset authored state", onClick: handleReset })
                : undefined)
            : undefined,
        React.createElement(interactive_iframe_1.InteractiveIframe, { src: interactive.url, width: "100%", height: "100%", initialAuthoredState: authoredState, initMsg: initMsg, resetCount: resetCount, onAuthoredStateChange: handleAuthoredStateChange, onSupportedFeaturesUpdate: handleSupportedFeatures, onHeightChange: handleHeightChange, onSetIFrameRef: handleSetIframeRef })));
};


/***/ }),

/***/ "./src/page-item-authoring/common/components/interactive-iframe.tsx":
/*!**************************************************************************!*\
  !*** ./src/page-item-authoring/common/components/interactive-iframe.tsx ***!
  \**************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var React = __webpack_require__(/*! react */ "react");
var react_1 = __webpack_require__(/*! react */ "react");
exports.InteractiveIframe = function (props) {
    var src = props.src, width = props.width, height = props.height, initMsg = props.initMsg, onAuthoredStateChange = props.onAuthoredStateChange, resetCount = props.resetCount, onSupportedFeaturesUpdate = props.onSupportedFeaturesUpdate, onHeightChange = props.onHeightChange, onSetIFrameRef = props.onSetIFrameRef;
    var iframe = react_1.useRef(null);
    onSetIFrameRef(iframe.current);
    var _a = react_1.useState(0), iframeId = _a[0], setIFrameId = _a[1];
    var phone;
    var connect = function () {
        console.log("connect");
        phone = new window.iframePhone.ParentEndpoint(iframe.current, function () {
            phone.post("initInteractive", initMsg);
        });
        phone.addListener("authoredState", function (authoredState) { return onAuthoredStateChange(authoredState); });
        phone.addListener("supportedFeatures", function (info) { return onSupportedFeaturesUpdate(info); });
        phone.addListener("height", function (newHeight) { return onHeightChange(newHeight); });
    };
    var disconnect = function () {
        if (phone) {
            phone.disconnect();
        }
    };
    var handleIframeLoaded = function () {
        connect();
    };
    react_1.useEffect(function () {
        return function () {
            console.log("useEffect disconnect");
            disconnect();
        };
    }, []);
    react_1.useEffect(function () {
        console.log("src/resetCount useEffect");
        if (iframe.current) {
            disconnect();
            setIFrameId(iframeId + 1);
        }
    }, [src, resetCount]);
    return (React.createElement("iframe", { ref: iframe, src: src, width: width, height: height, key: iframeId, frameBorder: "no", allowFullScreen: true, onLoad: handleIframeLoaded }));
};


/***/ }),

/***/ "./src/page-item-authoring/common/components/read-only-form-field.tsx":
/*!****************************************************************************!*\
  !*** ./src/page-item-authoring/common/components/read-only-form-field.tsx ***!
  \****************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var React = __webpack_require__(/*! react */ "react");
exports.ReadOnlyFormField = function (_a) {
    var legend = _a.legend, value = _a.value, inherit = _a.inherit, inherited = _a.inherited, inheritedValue = _a.inheritedValue, children = _a.children;
    var renderValue = function () {
        var renderedValue = inherit
            ? (inherited ? inheritedValue + " (inherited)" : value + " (customized)")
            : value;
        return (React.createElement(React.Fragment, null,
            renderedValue,
            children));
    };
    if (typeof legend !== undefined) {
        return (React.createElement("fieldset", null,
            React.createElement("legend", null, legend),
            renderValue()));
    }
    return renderValue();
};


/***/ }),

/***/ "./src/page-item-authoring/common/hooks/use-library-interactives.tsx":
/*!***************************************************************************!*\
  !*** ./src/page-item-authoring/common/hooks/use-library-interactives.tsx ***!
  \***************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var react_1 = __webpack_require__(/*! react */ "react");
exports.useLibraryInteractives = function () {
    var _a = react_1.useState({ state: "loading" }), state = _a[0], setState = _a[1];
    // load the list of interactives once at load time - this json is readable by admins and authors
    react_1.useEffect(function () {
        $.getJSON("/library_interactives")
            .done(function (list) {
            setState({ state: "loaded", list: list });
        })
            .fail(function (jqxhr, textStatus, error) {
            setState({ state: "error", error: error.toString() });
        });
    }, []);
    return state;
};


/***/ }),

/***/ "./src/page-item-authoring/common/utils/rails-form-field.ts":
/*!******************************************************************!*\
  !*** ./src/page-item-authoring/common/utils/rails-form-field.ts ***!
  \******************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
// returns a type-safe form id/name generator
exports.RailsFormField = function (name) {
    return function (field) { return ({
        id: name + "_" + field,
        name: name + "[" + field + "]",
    }); };
};


/***/ }),

/***/ "./src/page-item-authoring/index.tsx":
/*!*******************************************!*\
  !*** ./src/page-item-authoring/index.tsx ***!
  \*******************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var React = __webpack_require__(/*! react */ "react");
var ReactDOM = __webpack_require__(/*! react-dom */ "react-dom");
var managed_interactives_1 = __webpack_require__(/*! ./managed-interactives */ "./src/page-item-authoring/managed-interactives/index.tsx");
exports.ManagedInteractiveAuthoring = managed_interactives_1.ManagedInteractiveAuthoring;
var renderManagedInteractiveAuthoring = function (root, props) {
    return ReactDOM.render(React.createElement(managed_interactives_1.ManagedInteractiveAuthoring, { managedInteractive: props.managedInteractive, libraryInteractive: props.libraryInteractive, defaultClickToPlayPrompt: props.defaultClickToPlayPrompt }), root);
};
exports.renderManagedInteractiveAuthoring = renderManagedInteractiveAuthoring;
window.LARA.PageItemAuthoring = {
    renderManagedInteractiveAuthoring: renderManagedInteractiveAuthoring
};


/***/ }),

/***/ "./src/page-item-authoring/managed-interactives/customize.tsx":
/*!********************************************************************!*\
  !*** ./src/page-item-authoring/managed-interactives/customize.tsx ***!
  \********************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var React = __webpack_require__(/*! react */ "react");
var react_1 = __webpack_require__(/*! react */ "react");
var rails_form_field_1 = __webpack_require__(/*! ../common/utils/rails-form-field */ "./src/page-item-authoring/common/utils/rails-form-field.ts");
var read_only_form_field_1 = __webpack_require__(/*! ../common/components/read-only-form-field */ "./src/page-item-authoring/common/components/read-only-form-field.tsx");
var aspect_ratio_chooser_1 = __webpack_require__(/*! ../common/components/aspect-ratio-chooser */ "./src/page-item-authoring/common/components/aspect-ratio-chooser.tsx");
var formField = rails_form_field_1.RailsFormField("managed_interactive");
exports.CustomizeManagedInteractive = function (props) {
    var managedInteractive = props.managedInteractive, libraryInteractive = props.libraryInteractive, defaultClickToPlayPrompt = props.defaultClickToPlayPrompt;
    var url_fragment = managedInteractive.url_fragment, inherit_aspect_ratio_method = managedInteractive.inherit_aspect_ratio_method, custom_aspect_ratio_method = managedInteractive.custom_aspect_ratio_method, custom_native_width = managedInteractive.custom_native_width, custom_native_height = managedInteractive.custom_native_height, inherit_click_to_play = managedInteractive.inherit_click_to_play, custom_click_to_play = managedInteractive.custom_click_to_play, inherit_click_to_play_prompt = managedInteractive.inherit_click_to_play_prompt, custom_click_to_play_prompt = managedInteractive.custom_click_to_play_prompt, inherit_full_window = managedInteractive.inherit_full_window, custom_full_window = managedInteractive.custom_full_window, inherit_image_url = managedInteractive.inherit_image_url, custom_image_url = managedInteractive.custom_image_url;
    var _a = react_1.useState(inherit_aspect_ratio_method), inheritAspectRatio = _a[0], setInheritAspectRatio = _a[1];
    var _b = react_1.useState({
        width: custom_native_width,
        height: custom_native_height,
        mode: (custom_aspect_ratio_method || "DEFAULT")
    }), customAspectRatioValues = _b[0], setCustomAspectRatioValues = _b[1];
    var _c = react_1.useState(inherit_click_to_play), inheritClickToPlay = _c[0], setInheritClickToPlay = _c[1];
    var _d = react_1.useState(custom_click_to_play), customClickToPlay = _d[0], setCustomClickToPlay = _d[1];
    var _e = react_1.useState(inherit_click_to_play_prompt), inheritClickToPlayPrompt = _e[0], setInheritClickToPlayPrompt = _e[1];
    var _f = react_1.useState(custom_click_to_play_prompt), customClickToPlayPrompt = _f[0], setCustomClickToPlayPrompt = _f[1];
    var _g = react_1.useState(inherit_full_window), inheritFullWindow = _g[0], setInheritFullWindow = _g[1];
    var _h = react_1.useState(custom_full_window), customFullWindow = _h[0], setCustomFullWindow = _h[1];
    var _j = react_1.useState(inherit_image_url), inheritImageUrl = _j[0], setInheritImageUrl = _j[1];
    var _k = react_1.useState(custom_image_url), customImageUrl = _k[0], setCustomImageUrl = _k[1];
    var handleBooleanOption = function (setter) {
        return function (e) {
            var value = !!(e.target.checked && (e.target.value === "true"));
            setter(value);
        };
    };
    var handleStringOption = function (setter) {
        return function (e) {
            setter(e.target.value);
        };
    };
    var handleAspectRatioChange = function (values) { return setCustomAspectRatioValues(values); };
    var handleChangeCustomizeAspectRatio = handleBooleanOption(setInheritAspectRatio);
    var handleChangeClickToPlay = handleBooleanOption(setInheritClickToPlay);
    var handleChangeCustomClickToPlay = handleBooleanOption(setCustomClickToPlay);
    var handleChangeClickToPlayPrompt = handleBooleanOption(setInheritClickToPlayPrompt);
    var handleChangeCustomClickToPlayPrompt = handleStringOption(setCustomClickToPlayPrompt);
    var handleChangeFullWindow = handleBooleanOption(setInheritFullWindow);
    var handleChangeCustomFullWindow = handleBooleanOption(setCustomFullWindow);
    var handleChangeImageUrl = handleBooleanOption(setInheritImageUrl);
    var handleChangeCustomImageUrl = handleStringOption(setCustomImageUrl);
    var clickToPlayEnabled = (inheritClickToPlay && libraryInteractive.click_to_play) ||
        (!inheritClickToPlay && customClickToPlay);
    var handleUrlFragmentBlur = function (e) {
        props.onUrlFragmentChange(e.target.value);
    };
    if (!libraryInteractive.customizable) {
        var renderAspectRatioValues = function () {
            var mode = (inherit_aspect_ratio_method
                ? libraryInteractive.aspect_ratio_method
                : custom_aspect_ratio_method);
            if (mode !== "MANUAL") {
                return undefined;
            }
            var values = {
                width: inherit_aspect_ratio_method ? libraryInteractive.native_width : custom_native_width,
                height: inherit_aspect_ratio_method ? libraryInteractive.native_height : custom_native_height,
            };
            return React.createElement("span", { style: { marginLeft: 10 } },
                "(width: ",
                values.width,
                ", height: ",
                values.height,
                ")");
        };
        return (React.createElement("div", null,
            React.createElement("p", null,
                "The selected library interactive (",
                libraryInteractive.name,
                ") does not support customizing the advanced options.  Here are the default option values:"),
            React.createElement(read_only_form_field_1.ReadOnlyFormField, { legend: "Url Fragment", value: url_fragment }),
            React.createElement(read_only_form_field_1.ReadOnlyFormField, { legend: "Aspect Ratio", value: aspect_ratio_chooser_1.availableAspectRatios[custom_aspect_ratio_method], inherit: true, inherited: inherit_aspect_ratio_method, inheritedValue: aspect_ratio_chooser_1.availableAspectRatios[libraryInteractive.aspect_ratio_method] }, renderAspectRatioValues())));
    }
    var renderClickToPlayOptions = function () {
        var defaultPrompt = libraryInteractive.click_to_play_prompt || defaultClickToPlayPrompt;
        return React.createElement(React.Fragment, null,
            React.createElement("div", { className: "customizable-label" }, "Click To Play Prompt"),
            React.createElement("div", { className: "customizable-option" },
                React.createElement("input", { type: "radio", name: formField("inherit_click_to_play_prompt").name, value: "true", checked: inheritClickToPlayPrompt, onChange: handleChangeClickToPlayPrompt }),
                React.createElement("span", { className: "radio-label" },
                    "Use default: ",
                    React.createElement("strong", null,
                        "\"",
                        defaultPrompt,
                        "\""))),
            React.createElement("div", { className: "customizable-option" },
                React.createElement("input", { type: "radio", name: formField("inherit_click_to_play_prompt").name, value: "false", checked: !inheritClickToPlayPrompt, onChange: handleChangeClickToPlayPrompt }),
                React.createElement("span", { className: "radio-label" }, "Customize"),
                !inheritClickToPlayPrompt
                    ? React.createElement("input", { type: "text", name: formField("custom_click_to_play_prompt").name, value: customClickToPlayPrompt, onChange: handleChangeCustomClickToPlayPrompt })
                    : undefined),
            React.createElement("div", { className: "customizable-label" }, "Full Window"),
            React.createElement("div", { className: "customizable-option" },
                React.createElement("input", { type: "radio", name: formField("inherit_full_window").name, value: "true", checked: inheritFullWindow, onChange: handleChangeFullWindow }),
                React.createElement("span", { className: "radio-label" },
                    "Use default: ",
                    React.createElement("strong", null, libraryInteractive.click_to_play ? "Enabled" : "Disabled"))),
            React.createElement("div", { className: "customizable-option" },
                React.createElement("input", { type: "radio", name: formField("inherit_full_window").name, value: "false", checked: !inheritFullWindow, onChange: handleChangeFullWindow }),
                React.createElement("span", { className: "radio-label" }, "Customize"),
                !inheritFullWindow
                    ? React.createElement(React.Fragment, null,
                        React.createElement("input", { type: "checkbox", name: formField("custom_full_window").name, value: "true", checked: customFullWindow, onChange: handleChangeCustomFullWindow }),
                        " Enabled")
                    : undefined),
            React.createElement("div", { className: "customizable-label" }, "Image Url"),
            React.createElement("div", { className: "customizable-option" },
                React.createElement("input", { type: "radio", name: formField("inherit_image_url").name, value: "true", checked: inheritImageUrl, onChange: handleChangeImageUrl }),
                React.createElement("span", { className: "radio-label" },
                    "Use default: ",
                    React.createElement("strong", null,
                        "\"",
                        defaultPrompt,
                        "\""))),
            React.createElement("div", { className: "customizable-option" },
                React.createElement("input", { type: "radio", name: formField("inherit_image_url").name, value: "false", checked: !inheritImageUrl, onChange: handleChangeImageUrl }),
                React.createElement("span", { className: "radio-label" }, "Customize"),
                !inheritImageUrl
                    ? React.createElement("input", { type: "text", name: formField("custom_image_url").name, value: customImageUrl, onChange: handleChangeCustomImageUrl })
                    : undefined));
    };
    // this generates a form element that renders inside the rails popup form
    return React.createElement(React.Fragment, null,
        React.createElement("fieldset", null,
            React.createElement("legend", null, "Url Fragment"),
            React.createElement("textarea", { id: formField("url_fragment").id, name: formField("url_fragment").name, defaultValue: url_fragment, onBlur: handleUrlFragmentBlur })),
        React.createElement("fieldset", null,
            React.createElement("legend", null, "Aspect Ratio"),
            React.createElement("input", { type: "hidden", name: formField("custom_aspect_ratio_method").name, value: customAspectRatioValues.mode }),
            React.createElement("input", { type: "hidden", name: formField("inherit_native_width").name, value: inheritAspectRatio ? "true" : "false" }),
            React.createElement("input", { type: "hidden", name: formField("custom_native_width").name, value: customAspectRatioValues.width }),
            React.createElement("input", { type: "hidden", name: formField("inherit_native_height").name, value: inheritAspectRatio ? "true" : "false" }),
            React.createElement("input", { type: "hidden", name: formField("custom_native_height").name, value: customAspectRatioValues.height }),
            React.createElement("input", { type: "radio", name: formField("inherit_aspect_ratio_method").name, value: "true", checked: inheritAspectRatio, onChange: handleChangeCustomizeAspectRatio }),
            React.createElement("span", { className: "radio-label" }, "Use default: "),
            React.createElement("strong", null,
                aspect_ratio_chooser_1.availableAspectRatios[libraryInteractive.aspect_ratio_method],
                libraryInteractive.aspect_ratio_method === "MANUAL"
                    ? " (width: " + libraryInteractive.native_width + ", height: " + libraryInteractive.native_height + ")"
                    : undefined),
            React.createElement("div", { className: "customizable-option" },
                React.createElement("input", { type: "radio", name: formField("inherit_aspect_ratio_method").name, value: "false", checked: !inheritAspectRatio, onChange: handleChangeCustomizeAspectRatio }),
                React.createElement("span", { className: "radio-label" }, "Customize"),
                !inheritAspectRatio
                    ? React.createElement(aspect_ratio_chooser_1.AspectRatioChooser, { width: customAspectRatioValues.width, height: customAspectRatioValues.height, mode: customAspectRatioValues.mode, onChange: handleAspectRatioChange })
                    : undefined)),
        React.createElement("fieldset", null,
            React.createElement("legend", null, "Click to Play Options"),
            React.createElement("div", { className: "option_group" },
                React.createElement("div", { className: "customizable-label" }, "Enable Click To Play"),
                React.createElement("div", { className: "customizable-option" },
                    React.createElement("input", { type: "radio", name: formField("inherit_click_to_play").name, value: "true", checked: inheritClickToPlay, onChange: handleChangeClickToPlay }),
                    React.createElement("span", { className: "radio-label" },
                        "Use default: ",
                        React.createElement("strong", null, libraryInteractive.click_to_play ? "Enabled" : "Disabled"))),
                React.createElement("div", { className: "customizable-option" },
                    React.createElement("input", { type: "radio", name: formField("inherit_click_to_play").name, value: "false", checked: !inheritClickToPlay, onChange: handleChangeClickToPlay }),
                    React.createElement("span", { className: "radio-label" }, "Customize"),
                    !inheritClickToPlay
                        ? React.createElement(React.Fragment, null,
                            React.createElement("input", { type: "checkbox", name: formField("custom_click_to_play").name, value: "true", checked: customClickToPlay, onChange: handleChangeCustomClickToPlay }),
                            " Enabled")
                        : undefined),
                clickToPlayEnabled ? renderClickToPlayOptions() : undefined)));
};


/***/ }),

/***/ "./src/page-item-authoring/managed-interactives/index.tsx":
/*!****************************************************************!*\
  !*** ./src/page-item-authoring/managed-interactives/index.tsx ***!
  \****************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var React = __webpack_require__(/*! react */ "react");
var react_1 = __webpack_require__(/*! react */ "react");
var react_select_1 = __webpack_require__(/*! react-select */ "./node_modules/react-select/dist/react-select.browser.esm.js");
var react_tabs_1 = __webpack_require__(/*! react-tabs */ "./node_modules/react-tabs/esm/index.js");
var use_library_interactives_1 = __webpack_require__(/*! ../common/hooks/use-library-interactives */ "./src/page-item-authoring/common/hooks/use-library-interactives.tsx");
var interactive_authoring_1 = __webpack_require__(/*! ../common/components/interactive-authoring */ "./src/page-item-authoring/common/components/interactive-authoring.tsx");
__webpack_require__(/*! react-tabs/style/react-tabs.css */ "./node_modules/react-tabs/style/react-tabs.css");
var rails_form_field_1 = __webpack_require__(/*! ../common/utils/rails-form-field */ "./src/page-item-authoring/common/utils/rails-form-field.ts");
var customize_1 = __webpack_require__(/*! ./customize */ "./src/page-item-authoring/managed-interactives/customize.tsx");
var formField = rails_form_field_1.RailsFormField("managed_interactive");
exports.ManagedInteractiveAuthoring = function (props) {
    var managedInteractive = props.managedInteractive, defaultClickToPlayPrompt = props.defaultClickToPlayPrompt;
    var libraryInteractives = use_library_interactives_1.useLibraryInteractives();
    var _a = react_1.useState(props.libraryInteractive), libraryInteractive = _a[0], setLibraryInteractive = _a[1];
    var libraryInteractiveIdRef = react_1.useRef(null);
    var libraryInteractiveAuthoredStateRef = react_1.useRef(null);
    var _b = react_1.useState(managedInteractive.url_fragment), urlFragment = _b[0], setUrlFragment = _b[1];
    if (libraryInteractives.state === "loading") {
        return React.createElement("div", { className: "loading" }, "Loading library ...");
    }
    if (libraryInteractives.state === "error") {
        return React.createElement("div", { className: "error" }, libraryInteractives.error);
    }
    var createSelectOption = function (li) { return ({ value: li.id, label: li.name }); };
    var selectOptions = libraryInteractives.list.map(createSelectOption);
    var selectedOption = libraryInteractive ? createSelectOption(libraryInteractive) : undefined;
    var handleSelectChange = function (newSelectedOption) {
        var selectedLibraryInteractive = libraryInteractives.list.find(function (li) { return li.id === newSelectedOption.value; });
        setLibraryInteractive(selectedLibraryInteractive);
        if (libraryInteractiveIdRef.current) {
            libraryInteractiveIdRef.current.value = newSelectedOption.value.toString();
        }
    };
    var handleUrlFragmentChange = function (newUrlFragment) { return setUrlFragment(newUrlFragment); };
    var renderRequiredFields = function () {
        if (!libraryInteractive) {
            return undefined;
        }
        return React.createElement(React.Fragment, null,
            React.createElement("fieldset", null,
                React.createElement("legend", null, "Name"),
                React.createElement("input", { type: "text", id: formField("name").id, name: formField("name").name, defaultValue: managedInteractive.name })),
            React.createElement("fieldset", null,
                React.createElement("legend", null, "Options"),
                React.createElement("input", { type: "checkbox", id: formField("is_full_width").id, name: formField("is_full_width").name, defaultChecked: managedInteractive.is_full_width }),
                " Full width? (Full width layout only)",
                React.createElement("br", null),
                libraryInteractive.enable_learner_state ?
                    React.createElement(React.Fragment, null,
                        React.createElement("input", { type: "checkbox", id: formField("show_in_featured_question_report").id, name: formField("show_in_featured_question_report").name, defaultChecked: managedInteractive.show_in_featured_question_report }),
                        " Show in featured question report?")
                    : undefined));
    };
    var renderTabs = function () {
        if (!libraryInteractive) {
            return undefined;
        }
        var interactive = {
            url: "" + libraryInteractive.base_url + (urlFragment || ""),
            aspect_ratio_method: managedInteractive.inherit_aspect_ratio_method
                ? libraryInteractive.aspect_ratio_method
                : managedInteractive.custom_aspect_ratio_method,
            authored_state: managedInteractive.authored_state
        };
        var handleAuthoredStateChange = function (newAuthoredState) {
            if (libraryInteractiveAuthoredStateRef.current) {
                libraryInteractiveAuthoredStateRef.current.value = typeof newAuthoredState === "string"
                    ? newAuthoredState
                    : JSON.stringify(newAuthoredState);
            }
        };
        return (React.createElement(react_tabs_1.Tabs, null,
            React.createElement(react_tabs_1.TabList, null,
                React.createElement(react_tabs_1.Tab, null, "Authoring"),
                React.createElement(react_tabs_1.Tab, null, "Advanced Options")),
            React.createElement(react_tabs_1.TabPanel, { forceRender: true }, libraryInteractive.authorable
                ? React.createElement(interactive_authoring_1.InteractiveAuthoring, { interactive: interactive, onAuthoredStateChange: handleAuthoredStateChange, allowReset: false })
                : React.createElement("p", null,
                    "The selected library interactive (",
                    libraryInteractive.name,
                    ") does not support authoring.")),
            React.createElement(react_tabs_1.TabPanel, { forceRender: true },
                React.createElement(customize_1.CustomizeManagedInteractive, { libraryInteractive: libraryInteractive, managedInteractive: managedInteractive, defaultClickToPlayPrompt: defaultClickToPlayPrompt, onUrlFragmentChange: handleUrlFragmentChange }))));
    };
    // this generates a form element that renders inside the rails popup form
    return React.createElement(React.Fragment, null,
        React.createElement("fieldset", null,
            React.createElement("legend", null, "Library Interactive"),
            React.createElement("input", { type: "hidden", id: formField("library_interactive_id").id, name: formField("library_interactive_id").name, ref: libraryInteractiveIdRef, defaultValue: libraryInteractive ? "" + libraryInteractive.id : "" }),
            React.createElement("input", { type: "hidden", id: formField("authored_state").id, name: formField("authored_state").name, ref: libraryInteractiveAuthoredStateRef, defaultValue: managedInteractive.authored_state }),
            React.createElement(react_select_1.default, { value: selectedOption, onChange: handleSelectChange, options: selectOptions })),
        renderRequiredFields(),
        renderTabs());
};


/***/ }),

/***/ "react":
/*!************************!*\
  !*** external "React" ***!
  \************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE_react__;

/***/ }),

/***/ "react-dom":
/*!***************************!*\
  !*** external "ReactDOM" ***!
  \***************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE_react_dom__;

/***/ })

/******/ });
});
//# sourceMappingURL=page-item-authoring.js.map