// define our own subset of the iFramePhone API because the MockPhone is not
// sufficiently compatible with the actual iFramePhone API to replace it in
// tests, but the two do agree on the subset that we actually need.
export interface IFramePhoneStub {
  addListener: (type: string, fn: (content?: any) => void) => void;
  removeListener: (type: string) => void;
  post: (type: string, content?: any) => void;
}
export interface IFrameSaverPluginApi {
  disconnect: () => void;
}
export type IFrameSaverPlugin = (iframePhone: IFramePhoneStub) => IFrameSaverPluginApi;
