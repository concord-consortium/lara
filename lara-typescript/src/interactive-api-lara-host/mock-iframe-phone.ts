export const realIframePhone = jest.requireActual("iframe-phone");

class Messages {
  private _messages: any[] = [];

  public all() {
    return this._messages;
  }

  public at(idx: number) {
    return this._messages[idx];
  }

  public count() {
    return this._messages.length;
  }

  public reset() {
    this._messages = [];
  }

  public findType(type: string) {
    // tslint:disable-next-line:prefer-for-of
    for (let i = 0; i < this._messages.length; i++) {
      if (this._messages[i].message.type === type) return this._messages[i];
    }
    return null;
  }

  public _add(msg: any) {
    this._messages.push(msg);
  }
}

let autoConnect = true;
export const setAutoConnect = (value: boolean) => autoConnect = value;

export class MockIframePhoneManager {

  public messages: Messages;
  public _phones: any;
  private _phonesToConnect: MockPhone[];
  private _phonesCount: number;
  private _iframeEndpointInstance: any;

  constructor() {
    this.messages = new Messages();
    this._resetState();
  }

  // Call it before your test (e.g. beforeEach).
  public install() {
    this._resetState();
  }

  // Call it after your test (e.g. afterEach).
  public uninstall() {
    // Restore iframePhone module.
    this._resetState();
  }

  public _resetState() {
    this.messages.reset();
    this._phonesToConnect = [];
    this._phones = {};
    this._phonesCount = 0;
    this._iframeEndpointInstance = null;
    autoConnect = true;
  }

  public withMock(closure: () => void) {
    this.install();
    try {
      closure();
    } finally {
      this.uninstall();
    }
  }

  public connect() {
    this._phonesToConnect.forEach((phone) => {
      phone.fakeConnection();
    });
    this._phonesToConnect.length = 0;
  }

  public hasListener(type: string) {
    return Object.keys(this._phones)
            .some(phoneId => this._phones[phoneId].hasListener(type));
  }

  // Posts fake message from given element (e.g. iframe). Current window is the receiver.
  // If there is a mock iframe phones connected to source element, it will be notified.
  public postMessageFrom(source: HTMLElement, message: any) {
    this.messages._add({ source, target: window, message });
    const id = $(source).data("mock-iframe-phone-id");
    if (typeof id === "undefined") {
      // There was no iframe phone registered for this element.
      return;
    }
    Object.keys(this._phones).forEach(phoneId => {
      if (id !== phoneId) {
        this._phones[phoneId]._handleMessage(message);
      }
    });
  }

  public _registerPhone(element: Window | HTMLIFrameElement, phone: MockPhone) {
    const id = this._phonesCount++;
    // Save ID.
    $(element).data("mock-iframe-phone-id", id);
    this._phones[id] = phone;

    if (autoConnect) {
      phone.fakeConnection();
    } else {
      // Connection can be established later using .connectPhones().
      this._phonesToConnect.push(phone);
    }
  }
}

type Listener = (content?: any) => void;
type TargetOriginFn = () => void;
type AfterConnectedCallback = () => void | TargetOriginFn;

interface IMessage {
  type: string;
  content?: any;
}

export class MockPhone {

  public listeners: {[key: string]: Listener | null} = {};
  public messages: IMessage[] = [];

  public initialize = jest.fn();
  public disconnect = jest.fn();

  private targetElement: Window | HTMLIFrameElement;
  private _targetOrigin: string | TargetOriginFn | undefined;
  private afterConnectedCallback: AfterConnectedCallback | null | undefined;

  // tslint:disable-next-line:max-line-length
  constructor(targetElement: Window | HTMLIFrameElement, targetOrigin?: string | TargetOriginFn, afterConnectedCallback?: AfterConnectedCallback) {
    // Infer the origin ONLY if the user did not supply an explicit origin, i.e., if the second
    // argument is empty or is actually a callback (meaning it is supposed to be the
    // afterConnectionCallback)
    if (!targetOrigin || typeof targetOrigin === "function") {
      afterConnectedCallback = targetOrigin as AfterConnectedCallback;
      targetOrigin = this._getOrigin(targetElement);
    }

    this.targetElement = targetElement;
    this._targetOrigin = targetOrigin;
    this.afterConnectedCallback = afterConnectedCallback;
    this.listeners = {};

    MockedIframePhoneManager._registerPhone(targetElement, this);
  }

  public get numListeners() {
    return Object.keys(this.listeners).length;
  }

  public get listenerMessages() {
    return Object.keys(this.listeners);
  }

  // Mock-specific function, initializes fake connection.
  // It's important only if you care about afterConnectedCallback.
  public fakeConnection() {
    if (this.afterConnectedCallback) {
      this.afterConnectedCallback();
      this.afterConnectedCallback = null;
    }
  }

  public post(type: string | object, content: any) {
    let message;
    // Message object can be constructed from 'type' and 'content' arguments or it can be passed
    // as the first argument.
    if (arguments.length === 1 && typeof type === "object" && typeof (type as any).type === "string") {
      message = type;
    } else {
      message = {
        type,
        content
      };
    }
    this.messages.push(message as IMessage);
    MockedIframePhoneManager.messages._add({source: window, target: this.targetElement, message});
  }

  public hasListener(type: string) {
    return !!this.listeners[type];
  }

  public addListener(type: string, fn: Listener) {
    this.listeners[type] = fn;
  }

  public removeListener(type: string) {
    delete this.listeners[type];
  }

  public removeAllListeners() {
    this.listeners = {};
  }

  public getListenerNames() {
    return Object.keys(this.listeners);
  }

  public getTargetWindow() {
    return this.targetElement;
  }

  public targetOrigin() {
    return this._targetOrigin;
  }

  public reset() {
    this.listeners = {};
    this.messages = [];
    this.initialize.mockReset();
    this.disconnect.mockClear();
  }

  public fakeServerMessage(message: {type: string, content?: any}) {
    this._handleMessage(message);
  }

  private _handleMessage(message: {type: string, content?: any}) {
    if (this.listeners[message.type]) {
      this.listeners[message.type]!(message.content);
    }
  }

  private _getOrigin(element: any) {
    if (element.location && element.location.origin) {
      // window
      return element.location.origin;
    } else {
      // iframe
      const originMatch = element.src.match(/(.*?\/\/.*?)\//);
      return originMatch ? originMatch[1] : "";
    }
  }
}

let iframeEndpointInstance: MockPhone;
export const mockIFramePhone = (target = document.createElement("iframe")) => {
  return {
    ParentEndpoint: MockPhone,

    getIFrameEndpoint: () => {
      if (!iframeEndpointInstance) {
        iframeEndpointInstance = new MockPhone(target);
      }
      MockedIframePhoneManager._registerPhone(target, iframeEndpointInstance);
      return iframeEndpointInstance;
    },

    IframePhoneRpcEndpoint: realIframePhone.IframePhoneRpcEndpoint
  };
};

export const MockedIframePhoneManager = new MockIframePhoneManager();
