// Manager of the iframe phone instances.
// Do not use iframePhone module directly, use this class instead.

import * as iframePhone from "iframe-phone";
import { IframePhoneRpcEndpoint } from "iframe-phone";

type PhoneAnsweredCallback = () => void;

// initially phone is undefined to allow tp support case when
// afterConnectedCallback is executed synchronously right away in constructor (useful for tests).
interface IPhoneDataEntry {
  phoneAnswered: boolean;
  phoneAnsweredCallbacks: PhoneAnsweredCallback[];
  rpcEndpoints: {[key: string]: IframePhoneRpcEndpoint};
  phone?: iframePhone.ParentEndpoint;
}
type IPhoneDataEntryWithPhone = Required<IPhoneDataEntry>;

interface IPhoneData {
  [key: string]: IPhoneDataEntry;
}

export type AfterConnectedCallback = () => void;

export class IframePhoneManager {

  public static getPhone(iframeEl: HTMLIFrameElement, afterConnectedCallback?: AfterConnectedCallback) {
    return this.getInstance().getPhone(iframeEl, afterConnectedCallback);
  }

  public static getRpcEndpoint(iframeEl: HTMLIFrameElement, namespace: string) {
    return this.getInstance().getRpcEndpoint(iframeEl, namespace);
  }

  public static getInstance() {
    if (!this.instance) {
      this.instance = new IframePhoneManager();
    }
    return this.instance;
  }

  private static instance: IframePhoneManager | null = null;
  private iframeCount: number;
  private phoneData: IPhoneData;

  constructor() {
    this.iframeCount = 0;
    this.phoneData = {};
  }

  private getPhone(iframeEl: HTMLIFrameElement, afterConnectedCallback?: AfterConnectedCallback) {
    const data = this.iframePhoneData(iframeEl);

    if (afterConnectedCallback) {
      if (data.phoneAnswered) {
        // Ensure that callback is *always* executed in an async way.
        setTimeout((() => afterConnectedCallback()), 1);
      } else {
        data.phoneAnsweredCallbacks.push(afterConnectedCallback);
      }
    }

    return data.phone;
  }

  private getRpcEndpoint(iframeEl: HTMLIFrameElement, namespace: string) {
    const data = this.iframePhoneData(iframeEl);

    if (!data.rpcEndpoints[namespace]) {
      data.rpcEndpoints[namespace] = new iframePhone.IframePhoneRpcEndpoint({phone: data.phone, namespace});
    }
    return data.rpcEndpoints[namespace];
  }

  private iframePhoneData(iframeEl: HTMLIFrameElement): IPhoneDataEntryWithPhone {
    let phoneId = $(iframeEl).data("iframe-phone-id");
    if (phoneId === undefined) {
      phoneId = this.setupPhoneForIframe(iframeEl);
    }
    // phone is always set by setupPhoneForIframe()
    return this.phoneData[phoneId] as IPhoneDataEntryWithPhone;
  }

  private setupPhoneForIframe(iframeEl: HTMLIFrameElement) {
    const phoneId = this.iframeCount++;
    $(iframeEl).data("iframe-phone-id", phoneId);
    this.phoneData[phoneId] = {
      phoneAnswered: false,
      phoneAnsweredCallbacks: [],
      rpcEndpoints: {}
    };

    // Make sure that phone data is created before we create phone itself. It lets us support case when
    // afterConnectedCallback is executed synchronously right away in constructor (useful for tests).
    this.phoneData[phoneId].phone = new iframePhone.ParentEndpoint(iframeEl, () => this.phoneAnswered(iframeEl));

    return phoneId;
  }

  private phoneAnswered(iframeEl: HTMLIFrameElement) {
    const data = this.iframePhoneData(iframeEl);
    data.phoneAnswered = true;
    data.phoneAnsweredCallbacks.forEach(callback => callback());
  }
}
