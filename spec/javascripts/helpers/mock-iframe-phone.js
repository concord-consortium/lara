// Mock iframe phone implementation. Supports jasmine, but can be easily adapted to another test framework.
// See mock_iframe_phone_spec.coffee for example of use.

(function(global) {

  var mockIframePhoneManager = null;

  function MockIframePhoneManager() {
    this._realIframePhoneModule = global.iframePhone;

    // Messages object allows to inspect all recorded fake post messages.
    this.messages = {
      _messages: [],
      all: function() {
        return this._messages;
      },
      at: function(idx) {
        return this._messages[idx];
      },
      count: function() {
        return this._messages.length;
      },
      reset: function() {
        this._messages = [];
      },
      findType: function(type) {
        for (var i = 0; i < this._messages.length; i++) {
          if (this._messages[i].message.type === type) return this._messages[i];
        }
        return null;
      },
      _add: function(msg) {
        this._messages.push(msg);
      }
    };

    this._resetState();
  }

  // Call it before your test (e.g. beforeEach).
  MockIframePhoneManager.prototype.install = function() {
    // Mock iframePhone module.
    global.iframePhone = {
      ParentEndpoint: MockPhone,
      getIFrameEndpoint: function () {
        if (!this._iframeEndpointInstance) {
          this._iframeEndpointInstance = new MockPhone(window.parent);
        }
        return this._iframeEndpointInstance;
      }
    };
    this._resetState();
  };

  // Call it after your test (e.g. afterEach).
  MockIframePhoneManager.prototype.uninstall = function() {
    // Restore iframePhone module.
    global.iframePhone = this._realIframePhoneModule;
    this._resetState();
  };

  MockIframePhoneManager.prototype._resetState = function() {
    this.messages.reset();
    this.autoConnect = true;
    this._phonesToConnect = [];
    this._phones = {};
    this._phonesCount = 0;
    this._iframeEndpointInstance = null;
  };

  MockIframePhoneManager.prototype.withMock = function(closure) {
    this.install();
    try {
      closure();
    } finally {
      this.uninstall();
    }
  };

  MockIframePhoneManager.prototype.connect = function() {
    this._phonesToConnect.forEach(function (phone) {
      phone.fakeConnection();
    });
    this._phonesToConnect.length = 0;
  };

  // Posts fake message from given element (e.g. iframe). Current window is the receiver.
  // If there is a mock iframe phones connected to source element, it will be notified.
  MockIframePhoneManager.prototype.postMessageFrom = function(source, message) {
    this.messages._add({source: source, target: window, message: message});
    var id = $(source).data('mock-iframe-phone-id');
    if (typeof id === 'undefined') {
      // There was no iframe phone registered for this element.
      return;
    }
    this._phones[id]._handleMessage(message);
  };

  MockIframePhoneManager.prototype._registerPhone = function(element, phone) {
    var id = this._phonesCount++;
    // Save ID.
    $(element).data('mock-iframe-phone-id', id);
    this._phones[id] = phone;

    if (this.autoConnect) {
      phone.fakeConnection();
    } else {
      // Connection can be established later using .connectPhones().
      this._phonesToConnect.push(phone);
    }
  };

  // Mock iframe phone, implements interface of both ParentEndpoint and IframeEndpoint.
  function MockPhone(targetElement, targetOrigin, afterConnectedCallback) {
    // Infer the origin ONLY if the user did not supply an explicit origin, i.e., if the second
    // argument is empty or is actually a callback (meaning it is supposed to be the
    // afterConnectionCallback)
    if (!targetOrigin || targetOrigin.constructor === Function) {
      afterConnectedCallback = targetOrigin;
      targetOrigin = this._getOrigin(targetElement);
    }

    this._targetElement = targetElement;
    this._targetOrigin = targetOrigin;
    this._afterConnectedCallback = afterConnectedCallback;
    this._listeners = {};

    mockIframePhoneManager._registerPhone(targetElement, this);
  }

  // Mock-specific function, initializes fake connection.
  // It's important only if you care about afterConnectedCallback.
  MockPhone.prototype.fakeConnection = function() {
    if (this._afterConnectedCallback) {
      this._afterConnectedCallback();
      this._afterConnectedCallback = null;
    }
  };

  MockPhone.prototype.post = function(type, content) {
    var message;
    // Message object can be constructed from 'type' and 'content' arguments or it can be passed
    // as the first argument.
    if (arguments.length === 1 && typeof type === 'object' && typeof type.type === 'string') {
      message = type;
    } else {
      message = {
        type: type,
        content: content
      };
    }
    mockIframePhoneManager.messages._add({source: window, target: this._targetElement, message: message});
  };

  MockPhone.prototype.addListener = function(type, fn) {
    this._listeners[type] = fn;
  };

  MockPhone.prototype.removeListener = function(type) {
    this._listeners[messageName] = null;
  };

  MockPhone.prototype.removeAllListeners = function() {
    this._listeners = {};
  };

  MockPhone.prototype.getListenerNames = function() {
    return Object.keys(this._listeners);
  };

  MockPhone.prototype.getTargetWindow = function() {
    return this._targetElement;
  };

  MockPhone.prototype.targetOrigin = function() {
    return this._targetOrigin;
  };

  MockPhone.prototype.initialize = function() {
    // noop
  };

  MockPhone.prototype.disconnect = function() {
    // noop
  };

  MockPhone.prototype._handleMessage = function(message) {
    if (this._listeners[message.type]) {
      this._listeners[message.type](message.content);
    }
  };

  MockPhone.prototype._getOrigin = function(element) {
    if (element.location && element.location.origin) {
      // window
      return element.location.origin;
    } else {
      // iframe
      var originMatch = element.src.match(/(.*?\/\/.*?)\//);
      return originMatch ? originMatch[1] : '';
    }
  };

  // Initialize MockIframePhoneManager and make it available in Jasmine tests.
  mockIframePhoneManager = new MockIframePhoneManager(window);
  jasmine.mockIframePhone = mockIframePhoneManager;

}(typeof window === 'undefined' && typeof exports === 'object' ? exports : window));
