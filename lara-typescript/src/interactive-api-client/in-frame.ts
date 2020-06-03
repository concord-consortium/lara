const _inIframe = (() => {
  try {
    return window.self !== window.top;
  }
  catch (e) {
    return true;
  }
})();

export const inIframe = () => _inIframe;
