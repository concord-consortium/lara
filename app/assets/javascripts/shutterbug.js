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
    /***/ (function(module, __webpack_exports__, __webpack_require__) {

      "use strict";
      Object.defineProperty(__webpack_exports__, "__esModule", { value: true });

// EXTERNAL MODULE: external {"root":"jQuery","commonjs2":"jquery","commonjs":"jquery","amd":"jquery"}
      var external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery__ = __webpack_require__(0);
      var external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default = /*#__PURE__*/__webpack_require__.n(external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery__);

// CONCATENATED MODULE: ./js/html-tools.js


      function cloneDomItem($elem, elemTag) {
        const $returnElm = external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(elemTag);
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
        const format = 'image/png';
        const realWidth = external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(element).width();
        const realHeight = external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(element).height();
        const widthAttr = Number(external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(element).attr('width')) || realWidth;
        const heightAttr = Number(external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(element).attr('height')) || realHeight;
        if (realWidth === widthAttr && realHeight === heightAttr) {
          return element.toDataURL(format);
        }
        // Scale down image to its real size.
        const canvas = document.createElement('canvas');
        canvas.width = realWidth;
        canvas.height = realHeight;
        const ctx = canvas.getContext('2d');
        // Other canvas or video element can be used as a source in .drawImage.
        ctx.drawImage(element, 0, 0, realWidth, realHeight);
        return canvas.toDataURL(format);
      }

      function generateFullHtmlFromFragment(fragment) {
        return `
    <!DOCTYPE html> 
    <html> 
    <head> 
      <base href="${fragment.base_url}"> 
      <meta content="text/html;charset=utf-8" http-equiv="Content-Type"> 
      <title>content from ${fragment.base_url}</title> 
      ${fragment.css} 
    </head> 
      <body> 
        ${fragment.content} 
      </body> 
    </html>
   `;
      }
// CONCATENATED MODULE: ./js/default-server.js
      const DEFAULT_SERVER = 'https://fh1fzvhx93.execute-api.us-east-1.amazonaws.com/production';
// To work with local Shutterbug server use:
// const DEFAULT_SERVER = 'http://localhost:3000'
      /* harmony default export */ var default_server = (DEFAULT_SERVER);
// CONCATENATED MODULE: ./js/shutterbug-worker.js




      const MAX_TIMEOUT = 1500;

// Each shutterbug instance on a single page requires unique ID (iframe-iframe communication).
      let _id = 0;

      function getID() {
        return _id++;
      }

      class shutterbug_worker_ShutterbugWorker {
        constructor(options) {
          const opt = options || {};

          if (!opt.selector) {
            throw new Error('missing required option: selector');
          }

          // Remember that selector is anything accepted by jQuery, it can be DOM element too.
          this.element = opt.selector;
          this.callback = opt.done;
          this.failCallback = opt.fail;
          this.alwaysCallback = opt.always;
          this.imgDst = opt.dstSelector;
          this.server = opt.server || default_server;

          this.id = getID();
          this.iframeReqTimeout = MAX_TIMEOUT;

          // Bind and save a new function, so it works well with .add/removeEventListener().
          this._postMessageHandler = this._postMessageHandler.bind(this);
        }

        enableIframeCommunication() {
          external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(document).ready(() => {
            window.addEventListener('message', this._postMessageHandler, false);
        });
        }

        disableIframeCommunication() {
          window.removeEventListener('message', this._postMessageHandler, false);
        }

        getDomSnapshot() {
          this.enableIframeCommunication(); // !!!
          let timerID = null;
          if (this.imgDst) {
            // Start timer and update destination element.
            let time = 0;
            const counter = external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()('<span>');
            counter.html(time);
            external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(this.imgDst).html('Creating snapshot: ').append(counter);
            timerID = setInterval(() => {
              time = time + 1;
            counter.html(time);
          }, 1000);
          }
          // Ask for HTML fragment and render it on server.
          this.getHtmlFragment(htmlData => {
            external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default.a.ajax({
            url: this.server + '/make-snapshot',
            type: 'POST',
            data: JSON.stringify(htmlData)
          }).done(msg => {
            if (this.callback) {
            this.callback(msg.url);
          }
          if (this.imgDst) {
            external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(this.imgDst).html(`<img src=${msg.url}>`);
          }
        }).fail((jqXHR, textStatus, errorThrown) => {
            if (this.failCallback) {
            this.failCallback(jqXHR, textStatus, errorThrown);
          }
          if (this.imgDst) {
            external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(this.imgDst).html(`Snapshot failed`);
          }
          console.error(textStatus, errorThrown);
        }).always(() => {
            clearInterval(timerID);
          this.disableIframeCommunication(); // !!!
          if (this.alwaysCallback) {
            this.alwaysCallback();
          }
        });
        });
        }

        // Most important method. Returns HTML, CSS and dimensions of the snapshot.
        getHtmlFragment(callback) {
          const $element = external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(this.element);

          // .find('iframe').addBack("iframe") handles two cases:
          // - element itself is an iframe - .addBack('iframe')
          // - element descendants are iframes - .find('iframe')
          const $iframes = $element.find('iframe').addBack('iframe');
          this._iframeContentRequests = [];
          $iframes.each((i, iframeElem) => {
            // Note that position of the iframe is used as its ID.
            this._postHtmlFragRequestToIframe(iframeElem, i);
        });

          // Continue when we receive responses from all the nested iframes.
          // Nested iframes descriptions will be provided as arguments.
          external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default.a.when.apply(external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default.a, this._iframeContentRequests).done(function () {
            $element.trigger('shutterbug-saycheese');

            let clonedElement = $element.clone();

            // remove all script elements from the clone we don't want the html fragment
            // changing itself
            clonedElement.find('script').remove();

            // Nested iframes.
            if (arguments.length > 0) {
              const nestedIFrames = arguments;
              // This supports two cases:
              // - clonedElement itself is an iframe - .addBack('iframe')
              // - clonedElement descendants are iframes - .find('iframe')
              clonedElement.find('iframe').addBack('iframe').each(function (i, iframeElem) {
                // When iframe doesn't support Shutterbug, request will timeout and null will be received.
                // In such case just ignore this iframe, we won't be able to render it.
                if (nestedIFrames[i] == null) return;
                external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(iframeElem).attr('src', 'data:text/html,' + generateFullHtmlFromFragment(nestedIFrames[i]));
              });
            }

            // Canvases.
            // .addBack('canvas') handles case when the clonedElement itself is a canvas.
            const replacementCanvasImgs = $element.find('canvas').addBack('canvas').map(function (i, elem) {
              const dataUrl = getDataURL(elem);
              const img = cloneDomItem(external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(elem), '<img>');
              img.attr('src', dataUrl);
              return img;
            });

            if (clonedElement.is('canvas')) {
              clonedElement = replacementCanvasImgs[0];
            } else {
              clonedElement.find('canvas').each((i, elem) => {
                external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(elem).replaceWith(replacementCanvasImgs[i]);
            });
            }

            // Video elements.
            // .addBack('video') handles case when the clonedElement itself is a video.
            const replacementVideoImgs = [];
            $element.find('video').addBack('video').map((i, elem) => {
              const $elem = external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(elem);
            const canvas = cloneDomItem($elem, '<canvas>');
            canvas[0].getContext('2d').drawImage(elem, 0, 0, $elem.width(), $elem.height());
            try {
              const dataUrl = getDataURL(canvas[0]);
              const img = cloneDomItem($elem, '<img>');
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
                  external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(elem).replaceWith(replacementVideoImgs[i]);
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

            const htmlData = {
              content: external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()('<div>').append(clonedElement).html(),
              css: external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()('<div>').append(external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()('link[rel="stylesheet"]').clone()).append(external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()('style').clone()).html(),
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
        _postMessageHandler(message) {
          function handleMessage(message, type, handler) {
            let data = message.data;
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
        _htmlFragRequestHandler(data, source) {
          // Update timeout. When we receive a request from parent, we have to finish nested iframes
          // rendering in that time. Otherwise parent rendering will timeout.
          // Backward compatibility: Shutterbug v0.1.x don't send iframeReqTimeout.
          this.iframeReqTimeout = data.iframeReqTimeout != null ? data.iframeReqTimeout : MAX_TIMEOUT;
          this.getHtmlFragment(function (html) {
            const response = {
              type: 'htmlFragResponse',
              value: html,
              iframeReqId: data.iframeReqId,
              id: data.id // return to sender only
            };
            source.postMessage(JSON.stringify(response), '*');
          });
        }

        // Parent receives content from iframes.
        _htmlFragResponseHandler(data) {
          if (data.id === this.id) {
            // Backward compatibility: Shutterbug v0.1.x don't send iframeReqId.
            const iframeReqId = data.iframeReqId != null ? data.iframeReqId : 0;
            this._iframeContentRequests[iframeReqId].resolve(data.value);
          }
        }

        // Parent asks iframes about their content.
        _postHtmlFragRequestToIframe(iframeElem, iframeId) {
          const message = {
            type: 'htmlFragRequest',
            id: this.id,
            iframeReqId: iframeId,
            // We have to provide smaller timeout while sending message to nested iframes.
            // Otherwise, when one of the nested iframes timeouts, then all will do the
            // same and we won't render anything - even iframes that support Shutterbug.
            iframeReqTimeout: this.iframeReqTimeout * 0.6
          };
          iframeElem.contentWindow.postMessage(JSON.stringify(message), '*');
          const requestDeferred = new external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default.a.Deferred();
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
      }
// CONCATENATED MODULE: ./js/index.js



// Used by enable and disable functions.
      let iframeWorker = null;

      function parseSnapshotArguments(args) {
        // Remember that selector is anything accepted by jQuery, it can be DOM element too.
        let selector;
        let doneCallback;
        let dstSelector;
        let options = {};

        function assignSecondArgument(arg) {
          if (typeof arg === 'string') {
            dstSelector = arg;
          } else if (typeof arg === 'function') {
            doneCallback = arg;
          } else if (typeof arg === 'object') {
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
      /* harmony default export */ var js = __webpack_exports__["default"] = ({
        snapshot() {
          const options = parseSnapshotArguments(arguments);
          const shutterbugWorker = new shutterbug_worker_ShutterbugWorker(options);
          shutterbugWorker.getDomSnapshot();
        },

        enable(selector) {
          this.disable();
          selector = selector || 'body';
          iframeWorker = new shutterbug_worker_ShutterbugWorker({ selector: selector });
          iframeWorker.enableIframeCommunication();
        },

        disable() {
          if (iframeWorker) {
            iframeWorker.disableIframeCommunication();
            iframeWorker = null;
          }
        },

        // Supported events:
        // 'saycheese' - triggered before snapshot is taken
        // 'asyouwere' - triggered after snapshot is taken
        on(event, handler) {
          external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(window).on('shutterbug-' + event, handler);
        },

        off(event, handler) {
          external___root___jQuery___commonjs2___jquery___commonjs___jquery___amd___jquery___default()(window).off('shutterbug-' + event, handler);
        }
      });

      /***/ })
    /******/ ])["default"];
});
