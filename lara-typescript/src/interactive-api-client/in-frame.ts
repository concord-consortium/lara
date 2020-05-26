let _inIframe = (() => {
  try {
    return window.self !== window.top;
  }
  catch (e) {
    return true;
  }
})();

export const setInIframe = (value: boolean) => {
  _inIframe = value;
};

export const inIframe = () => _inIframe;
