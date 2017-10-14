(function webpackUniversalModuleDefinition(root, factory) {
  if(typeof exports === 'object' && typeof module === 'object')
    module.exports = factory(require("jquery"));
  else if(typeof define === 'function' && define.amd)
    define(["jquery"], factory);
  else if(typeof exports === 'object')
    exports["shutterbug"] = factory(require("jquery"));
  else
    root["Shutterbug"] = factory(root["jQuery"]);
})(this, function(__WEBPACK_EXTERNAL_MODULE_0__) {
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
        /******/ 			Object.defineProperty(exports, name, {
          /******/ 				configurable: false,
          /******/ 				enumerable: true,
          /******/ 				get: getter
          /******/ 			});
        /******/ 		}
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
    /******/ 	// Load entry module and return exports
    /******/ 	return __webpack_require__(__webpack_require__.s = 1);
    /******/ })
  /************************************************************************/
  /******/ ([
    /* 0 */
    /***/ (function(module, exports) {

      module.exports = __WEBPACK_EXTERNAL_MODULE_0__;

      /***/ }),
    /* 1 */
    /***/ (function(module, exports, __webpack_require__) {

      "use strict";


      Object.defineProperty(exports, "__esModule", {
        value: true
      });

      var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

      var _jquery = __webpack_require__(0);

      var _jquery2 = _interopRequireDefault(_jquery);

      var _shutterbugWorker = __webpack_require__(2);

      var _shutterbugWorker2 = _interopRequireDefault(_shutterbugWorker);

      function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// Used by enable and disable functions.
      var iframeWorker = null;

      function parseSnapshotArguments(args) {
        // Remember that selector is anything accepted by jQuery, it can be DOM element too.
        var selector = void 0;
        var doneCallback = void 0;
        var dstSelector = void 0;
        var options = {};

        function assignSecondArgument(arg) {
          if (typeof arg === 'string') {
            dstSelector = arg;
          } else if (typeof arg === 'function') {
            doneCallback = arg;
          } else if ((typeof arg === 'undefined' ? 'undefined' : _typeof(arg)) === 'object') {
            options = arg;
          }
        }

        if (args.length === 3) {
          options = args[2];
          assignSecondArgument(args[1]);
          selector = args[0];
        } else if (args.length === 2) {
          assignSecondArgument(args[1]);
          selector = args[0];
        } else if (args.length === 1) {
          options = args[0];
        }
        if (selector) {
          options.selector = selector;
        }
        if (doneCallback) {
          options.done = doneCallback;
        }
        if (dstSelector) {
          options.dstSelector = dstSelector;
        }
        return options;
      }

// Public API:
      exports.default = {
        snapshot: function snapshot() {
          var options = parseSnapshotArguments(arguments);
          var shutterbugWorker = new _shutterbugWorker2.default(options);
          shutterbugWorker.getDomSnapshot();
        },
        enable: function enable(selector) {
          this.disable();
          selector = selector || 'body';
          iframeWorker = new _shutterbugWorker2.default({ selector: selector });
          iframeWorker.enableIframeCommunication();
        },
        disable: function disable() {
          if (iframeWorker) {
            iframeWorker.disableIframeCommunication();
            iframeWorker = null;
          }
        },


        // Supported events:
        // 'saycheese' - triggered before snapshot is taken
        // 'asyouwere' - triggered after snapshot is taken
        on: function on(event, handler) {
          (0, _jquery2.default)(window).on('shutterbug-' + event, handler);
        },
        off: function off(event, handler) {
          (0, _jquery2.default)(window).off('shutterbug-' + event, handler);
        }
      };

      /***/ }),
    /* 2 */
    /***/ (function(module, exports, __webpack_require__) {

      "use strict";


      Object.defineProperty(exports, "__esModule", {
        value: true
      });

      var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

      var _jquery = __webpack_require__(0);

      var _jquery2 = _interopRequireDefault(_jquery);

      var _htmlTools = __webpack_require__(3);

      var _defaultServer = __webpack_require__(4);

      var _defaultServer2 = _interopRequireDefault(_defaultServer);

      function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

      function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

      var MAX_TIMEOUT = 1500;

// Each shutterbug instance on a single page requires unique ID (iframe-iframe communication).
      var _id = 0;

      function getID() {
        return _id++;
      }

      var ShutterbugWorker = function () {
        function ShutterbugWorker(options) {
          _classCallCheck(this, ShutterbugWorker);

          var opt = options || {};

          if (!opt.selector) {
            throw new Error('missing required option: selector');
          }

          // Remember that selector is anything accepted by jQuery, it can be DOM element too.
          this.element = opt.selector;
          this.callback = opt.done;
          this.failCallback = opt.fail;
          this.alwaysCallback = opt.always;
          this.imgDst = opt.dstSelector;
          this.server = opt.server || _defaultServer2.default;

          this.id = getID();
          this.iframeReqTimeout = MAX_TIMEOUT;

          // Bind and save a new function, so it works well with .add/removeEventListener().
          this._postMessageHandler = this._postMessageHandler.bind(this);
        }

        _createClass(ShutterbugWorker, [{
          key: 'enableIframeCommunication',
          value: function enableIframeCommunication() {
            var _this = this;

            (0, _jquery2.default)(document).ready(function () {
              window.addEventListener('message', _this._postMessageHandler, false);
            });
          }
        }, {
          key: 'disableIframeCommunication',
          value: function disableIframeCommunication() {
            window.removeEventListener('message', this._postMessageHandler, false);
          }
        }, {
          key: 'getDomSnapshot',
          value: function getDomSnapshot() {
            var _this2 = this;

            this.enableIframeCommunication(); // !!!
            var timerID = null;
            if (this.imgDst) {
              // Start timer and update destination element.
              var time = 0;
              var counter = (0, _jquery2.default)('<span>');
              counter.html(time);
              (0, _jquery2.default)(this.imgDst).html('Creating snapshot: ').append(counter);
              timerID = setInterval(function () {
                time = time + 1;
                counter.html(time);
              }, 1000);
            }
            // Ask for HTML fragment and render it on server.
            this.getHtmlFragment(function (htmlData) {
              _jquery2.default.ajax({
                url: _this2.server + '/make-snapshot',
                type: 'POST',
                data: JSON.stringify(htmlData)
              }).done(function (msg) {
                if (_this2.callback) {
                  _this2.callback(msg.url);
                }
                if (_this2.imgDst) {
                  (0, _jquery2.default)(_this2.imgDst).html('<img src=' + msg.url + '>');
                }
              }).fail(function (jqXHR, textStatus, errorThrown) {
                if (_this2.failCallback) {
                  _this2.failCallback(jqXHR, textStatus, errorThrown);
                }
                if (_this2.imgDst) {
                  (0, _jquery2.default)(_this2.imgDst).html('Snapshot failed');
                }
                console.error(textStatus, errorThrown);
              }).always(function () {
                clearInterval(timerID);
                _this2.disableIframeCommunication(); // !!!
                if (_this2.alwaysCallback) {
                  _this2.alwaysCallback();
                }
              });
            });
          }

          // Most important method. Returns HTML, CSS and dimensions of the snapshot.

        }, {
          key: 'getHtmlFragment',
          value: function getHtmlFragment(callback) {
            var _this3 = this;

            var $element = (0, _jquery2.default)(this.element);

            // .find('iframe').addBack("iframe") handles two cases:
            // - element itself is an iframe - .addBack('iframe')
            // - element descendants are iframes - .find('iframe')
            var $iframes = $element.find('iframe').addBack('iframe');
            this._iframeContentRequests = [];
            $iframes.each(function (i, iframeElem) {
              // Note that position of the iframe is used as its ID.
              _this3._postHtmlFragRequestToIframe(iframeElem, i);
            });

            // Continue when we receive responses from all the nested iframes.
            // Nested iframes descriptions will be provided as arguments.
            _jquery2.default.when.apply(_jquery2.default, this._iframeContentRequests).done(function () {
              $element.trigger('shutterbug-saycheese');

              var clonedElement = $element.clone();

              // remove all script elements from the clone we don't want the html fragment
              // changing itself
              clonedElement.find('script').remove();

              // Nested iframes.
              if (arguments.length > 0) {
                var nestedIFrames = arguments;
                // This supports two cases:
                // - clonedElement itself is an iframe - .addBack('iframe')
                // - clonedElement descendants are iframes - .find('iframe')
                clonedElement.find('iframe').addBack('iframe').each(function (i, iframeElem) {
                  // When iframe doesn't support Shutterbug, request will timeout and null will be received.
                  // In such case just ignore this iframe, we won't be able to render it.
                  if (nestedIFrames[i] == null) return;
                  (0, _jquery2.default)(iframeElem).attr('src', 'data:text/html,' + (0, _htmlTools.generateFullHtmlFromFragment)(nestedIFrames[i]));
                });
              }

              // Canvases.
              // .addBack('canvas') handles case when the clonedElement itself is a canvas.
              var replacementCanvasImgs = $element.find('canvas').addBack('canvas').map(function (i, elem) {
                var dataUrl = (0, _htmlTools.getDataURL)(elem);
                var img = (0, _htmlTools.cloneDomItem)((0, _jquery2.default)(elem), '<img>');
                img.attr('src', dataUrl);
                return img;
              });

              if (clonedElement.is('canvas')) {
                clonedElement = replacementCanvasImgs[0];
              } else {
                clonedElement.find('canvas').each(function (i, elem) {
                  (0, _jquery2.default)(elem).replaceWith(replacementCanvasImgs[i]);
                });
              }

              // Video elements.
              // .addBack('video') handles case when the clonedElement itself is a video.
              var replacementVideoImgs = [];
              $element.find('video').addBack('video').map(function (i, elem) {
                var $elem = (0, _jquery2.default)(elem);
                var canvas = (0, _htmlTools.cloneDomItem)($elem, '<canvas>');
                canvas[0].getContext('2d').drawImage(elem, 0, 0, $elem.width(), $elem.height());
                try {
                  var dataUrl = (0, _htmlTools.getDataURL)(canvas[0]);
                  var img = (0, _htmlTools.cloneDomItem)($elem, '<img>');
                  img.attr('src', dataUrl);
                  replacementVideoImgs.push(img);
                } catch (e) {
                  // If the video isn't hosted on the same site this will catch the security error
                  // and push null to signal it doesn't need replacing.  We don't use the return
                  // value of map() as returning null confuses jQuery.
                  replacementVideoImgs.push(null);
                }
              });

              if (clonedElement.is('video')) {
                if (replacementVideoImgs[0]) {
                  clonedElement = replacementVideoImgs[0];
                }
              } else {
                clonedElement.find('video').each(function (i, elem) {
                  if (replacementVideoImgs[i]) {
                    (0, _jquery2.default)(elem).replaceWith(replacementVideoImgs[i]);
                  }
                });
              }

              clonedElement.css({
                // Make sure that clonedElement will be positioned in the top-left corner of the viewport.
                'top': 0,
                'left': 0,
                'transform': 'translate3d(0, 0, 0)',
                'margin': 0,
                // Dimensions need to be set explicitly (e.g. otherwise 50% width wouldn't work as expected).
                'width': $element.width(),
                'height': $element.height()
              });

              var htmlData = {
                content: (0, _jquery2.default)('<div>').append(clonedElement).html(),
                css: (0, _jquery2.default)('<div>').append((0, _jquery2.default)('link[rel="stylesheet"]').clone()).append((0, _jquery2.default)('style').clone()).html(),
                width: $element.outerWidth(),
                height: $element.outerHeight(),
                base_url: window.location.href
              };

              $element.trigger('shutterbug-asyouwere');

              callback(htmlData);
            });
          }

          // frame-iframe communication related methods:

          // Basic post message handler.

        }, {
          key: '_postMessageHandler',
          value: function _postMessageHandler(message) {
            function handleMessage(message, type, handler) {
              var data = message.data;
              if (typeof data === 'string') {
                try {
                  data = JSON.parse(data);
                  if (data.type === type) {
                    handler(data, message.source);
                  }
                } catch (e) {
                  // Not a json message. Ignore it. We only speak json.
                }
              }
            }

            handleMessage(message, 'htmlFragRequest', this._htmlFragRequestHandler.bind(this));
            handleMessage(message, 'htmlFragResponse', this._htmlFragResponseHandler.bind(this));
          }

          // Iframe receives question about its content.

        }, {
          key: '_htmlFragRequestHandler',
          value: function _htmlFragRequestHandler(data, source) {
            // Update timeout. When we receive a request from parent, we have to finish nested iframes
            // rendering in that time. Otherwise parent rendering will timeout.
            // Backward compatibility: Shutterbug v0.1.x don't send iframeReqTimeout.
            this.iframeReqTimeout = data.iframeReqTimeout != null ? data.iframeReqTimeout : MAX_TIMEOUT;
            this.getHtmlFragment(function (html) {
              var response = {
                type: 'htmlFragResponse',
                value: html,
                iframeReqId: data.iframeReqId,
                id: data.id // return to sender only
              };
              source.postMessage(JSON.stringify(response), '*');
            });
          }

          // Parent receives content from iframes.

        }, {
          key: '_htmlFragResponseHandler',
          value: function _htmlFragResponseHandler(data) {
            if (data.id === this.id) {
              // Backward compatibility: Shutterbug v0.1.x don't send iframeReqId.
              var iframeReqId = data.iframeReqId != null ? data.iframeReqId : 0;
              this._iframeContentRequests[iframeReqId].resolve(data.value);
            }
          }

          // Parent asks iframes about their content.

        }, {
          key: '_postHtmlFragRequestToIframe',
          value: function _postHtmlFragRequestToIframe(iframeElem, iframeId) {
            var message = {
              type: 'htmlFragRequest',
              id: this.id,
              iframeReqId: iframeId,
              // We have to provide smaller timeout while sending message to nested iframes.
              // Otherwise, when one of the nested iframes timeouts, then all will do the
              // same and we won't render anything - even iframes that support Shutterbug.
              iframeReqTimeout: this.iframeReqTimeout * 0.6
            };
            iframeElem.contentWindow.postMessage(JSON.stringify(message), '*');
            var requestDeferred = new _jquery2.default.Deferred();
            this._iframeContentRequests[iframeId] = requestDeferred;
            setTimeout(function () {
              // It handles a situation in which iframe doesn't support Shutterbug.
              // When we doesn't receive answer for some time, assume that we can't
              // render this particular iframe (provide null as iframe description).
              if (requestDeferred.state() !== 'resolved') {
                requestDeferred.resolve(null);
              }
            }, this.iframeReqTimeout);
          }
        }]);

        return ShutterbugWorker;
      }();

      exports.default = ShutterbugWorker;

      /***/ }),
    /* 3 */
    /***/ (function(module, exports, __webpack_require__) {

      "use strict";


      Object.defineProperty(exports, "__esModule", {
        value: true
      });
      exports.cloneDomItem = cloneDomItem;
      exports.getDataURL = getDataURL;
      exports.generateFullHtmlFromFragment = generateFullHtmlFromFragment;

      var _jquery = __webpack_require__(0);

      var _jquery2 = _interopRequireDefault(_jquery);

      function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

      function cloneDomItem($elem, elemTag) {
        var $returnElm = (0, _jquery2.default)(elemTag);
        $returnElm.addClass($elem.attr('class'));
        $returnElm.attr('id', $elem.attr('id'));
        $returnElm.attr('style', $elem.attr('style'));
        $returnElm.css('background', $elem.css('background'));
        $returnElm.attr('width', $elem.width());
        $returnElm.attr('height', $elem.height());
        return $returnElm;
      }

// element should be an instance of Canvas or Video element (element supported as an input to Canvas.drawImage method).
// In some cases dataURL should be rescaled down to real size of the element (high DPI displays).
// It doesn't make sense to send original data, as it might be really large and cause issues while rendering page on
// AWS Lambda.
      function getDataURL(element) {
        // Always use png to support transparent background.
        var format = 'image/png';
        var realWidth = (0, _jquery2.default)(element).width();
        var realHeight = (0, _jquery2.default)(element).height();
        var widthAttr = Number((0, _jquery2.default)(element).attr('width')) || realWidth;
        var heightAttr = Number((0, _jquery2.default)(element).attr('height')) || realHeight;
        if (realWidth === widthAttr && realHeight === heightAttr) {
          return element.toDataURL(format);
        }
        // Scale down image to its real size.
        var canvas = document.createElement('canvas');
        canvas.width = realWidth;
        canvas.height = realHeight;
        var ctx = canvas.getContext('2d');
        // Other canvas or video element can be used as a source in .drawImage.
        ctx.drawImage(element, 0, 0, realWidth, realHeight);
        return canvas.toDataURL(format);
      }

      function generateFullHtmlFromFragment(fragment) {
        return '\n    <!DOCTYPE html> \n    <html> \n    <head> \n      <base href="' + fragment.base_url + '"> \n      <meta content="text/html;charset=utf-8" http-equiv="Content-Type"> \n      <title>content from ' + fragment.base_url + '</title> \n      ' + fragment.css + ' \n    </head> \n      <body> \n        ' + fragment.content + ' \n      </body> \n    </html>\n   ';
      }

      /***/ }),
    /* 4 */
    /***/ (function(module, exports, __webpack_require__) {

      "use strict";


      Object.defineProperty(exports, "__esModule", {
        value: true
      });
      var DEFAULT_SERVER = 'https://fh1fzvhx93.execute-api.us-east-1.amazonaws.com/production';
// To work with local Shutterbug server use:
// const DEFAULT_SERVER = 'http://localhost:3000'
      exports.default = DEFAULT_SERVER;

      /***/ })
    /******/ ])["default"];
});
