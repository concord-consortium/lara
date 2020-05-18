describe("GlobalIFrameSaver", () => {
  it("TODO", () => {
    expect(true).toBe(true);
  });
});

/*
describe('GlobalIframeSaver', function() {
  beforeEach(function() {
    loadFixtures("global-iframe-saver.html"); // just 3 iframes
    jasmine.Ajax.install();
    jasmine.mockIframePhone.install();
    this.saveUrl = 'https://lara.url/global_state_endpoint';
    return this.globalState = {key: 'val'};});

  afterEach(function() {
    jasmine.Ajax.uninstall();
    return jasmine.mockIframePhone.uninstall();
  });

  it('should broadcast global state if it is provided in config', function() {
    this.globalSaver = new GlobalIframeSaver({save_url: this.saveUrl, raw_data: JSON.stringify(this.globalState)});

    $('iframe').each((idx, iframeEl) => {
      return this.globalSaver.addNewInteractive(iframeEl);
    });

    expect(jasmine.mockIframePhone.messages.count()).toEqual(3);
    return $('iframe').each((idx, iframeEl) => {
      return expect(jasmine.mockIframePhone.messages.at(idx)).toEqual({
        source: window,
        target: iframeEl,
        message: {
          type: 'loadInteractiveGlobal',
          content: this.globalState
        }
      });
    });
  });

  return describe('when "interactiveStateGlobal" message is received from iframe', function() {
    beforeEach(function() {
      this.globalSaver = new GlobalIframeSaver({save_url: this.saveUrl});

      $('iframe').each((idx, iframeEl) => {
        return this.globalSaver.addNewInteractive(iframeEl);
      });

      return jasmine.mockIframePhone.postMessageFrom($('iframe')[0], {
        type: 'interactiveStateGlobal', content: this.globalState
      });});

    it('should broadcast "loadInteractiveGlobal" to other iframes', function() {
      expect(jasmine.mockIframePhone.messages.count()).toEqual(3);
      // Initial message.
      expect(jasmine.mockIframePhone.messages.at(0)).toEqual({
        source: $('iframe')[0],
        target: window,
        message: {
          type: 'interactiveStateGlobal',
          content: this.globalState
        }
      });
      // Messages posted by GlobalIframeSaver:
      expect(jasmine.mockIframePhone.messages.at(1)).toEqual({
        source: window,
        target: $('iframe')[1],
        message: {
          type: 'loadInteractiveGlobal',
          content: this.globalState
        }
      });
      return expect(jasmine.mockIframePhone.messages.at(2)).toEqual({
        source: window,
        target: $('iframe')[2],
        message: {
          type: 'loadInteractiveGlobal',
          content: this.globalState
        }
      });
    });

    return it('should send state to LARA server', function() {
      const request = jasmine.Ajax.requests.mostRecent();
      expect(request.url).toBe(this.saveUrl);
      expect(request.method).toBe('POST');
      // No idea why raw data needs to be wrapped in array - caused by jQuery or MockAjax?
      return expect(request.data()).toEqual({raw_data: [JSON.stringify(this.globalState)]});
  });
});
});
*/
