describe("IFrameSaver", () => {
  it("TODO", () => {
    expect(true).toBe(true);
  });
});

/*
const success_response = {
  status: 200,
  responseText: '{}'
};

// this spec is very out of date with the current code
describe('IFrameSaver', function() {
  let saver               = null;
  let request             = null;
  const iframePhone         = jasmine.mockIframePhone;

  beforeEach(function() {
    iframePhone.install();
    iframePhone.autoConnect = false;
    return loadFixtures("iframe-saver.html");
  });

  afterEach(() => iframePhone.uninstall());

  const getSaver = () => new IFrameSaver($('#interactive'), $('#interactive_data_div'), $('.delete_interactive_data'));

  describe("with an interactive in in iframe", function() {
    const fake_save_indicator = jasmine.createSpyObj('SaveIndicator',['showSaved','showSaving', 'showSaveFailed']);

    beforeEach(function() {
      saver = getSaver();
      return saver.save_indicator = fake_save_indicator;
    });

    describe("a sane testing environment", function() {
      it('has an instance of IFrameSaver defined', () => expect(saver).toBeDefined());

      it('has an iframe to work with', () => expect($("#interactive")[0]).toExist());

      return it('has an interactive data element', () => expect($("#interactive_data_div")).toExist());
    });

    describe("constructor called in the correct context", () => {
      it("should have a interactive run state url", () => expect(saver.interactive_run_state_url).toBe("foo/42")));
    });

    describe("save", function() {
      beforeEach(() => saver.save());

      return it("invokes the correct message on the iframePhone", () => {
        expect(iframePhone.messages.findType('getInteractiveState')).toBeTruthy());
      });
    });

    return describe("save_learner_state", function() {
      beforeEach(function() {
        jasmine.Ajax.install();
        saver.save_learner_state({foo:'bar'});
        request = jasmine.Ajax.requests.mostRecent();
        return request.respondWith(success_response);
      });

      afterEach(() => jasmine.Ajax.uninstall());

      return describe("a successful save", () => it("should display the show saved indicator", function() {
        expect(fake_save_indicator.showSaveFailed).not.toHaveBeenCalled();
        expect(fake_save_indicator.showSaving).toHaveBeenCalled();
        return expect(fake_save_indicator.showSaved).toHaveBeenCalled();
      }));
    });
  });

  return describe("interactive initialization", function() {
    describe("when state saving is enabled", function() {
      beforeEach(function() {
        jasmine.Ajax.install();
        $("#interactive_data_div").data("enable-learner-state", true);
        saver = getSaver();
        iframePhone.connect();
        request = jasmine.Ajax.requests.mostRecent();
        return request.respondWith({
          status: 200,
          responseText: JSON.stringify({
            "raw_data": JSON.stringify({"interactiveState": 321}),
            "created_at": "2017",
            "updated_at": "2018",
            "activity_name": "test act",
            "page_name": "test page",
            "page_number": 2
          })
        });
      });

      afterEach(() => jasmine.Ajax.uninstall());

      return it("should post 'initInteractive'", () => {
        expect(iframePhone.messages.findType('initInteractive').message.content).toEqual({
          version: 1,
          error: null,
          mode: 'runtime',
          authoredState: {test: 123},
          interactiveState: {interactiveState: 321},
          createdAt: '2017',
          updatedAt: '2018',
          globalInteractiveState: null,
          interactiveStateUrl: 'foo/42',
          collaboratorUrls: null,
          classInfoUrl: null,
          interactive: {id: 1, name: "test"},
          authInfo: {provider: "fakeprovider", loggedIn: true, email: "user@example.com"},
          pageNumber: 2,
          pageName: "test page",
          activityName: "test act"
        })});
    });

    return describe("when state saving is disabled", function() {
      beforeEach(function() {
        $("#interactive_data_div").data("enable-learner-state", false);
        saver = getSaver();
        return iframePhone.connect();
      });

      return it("should post 'initInteractive'", () => {
        expect(iframePhone.messages.findType('initInteractive').message.content).toEqual({
          version: 1,
          error: null,
          mode: 'runtime',
          authoredState: {test: 123},
          interactiveState: null,
          globalInteractiveState: null,
          interactiveStateUrl: 'foo/42',
          collaboratorUrls: null,
          classInfoUrl: null,
          interactive: {id: 1, name: "test"},
          authInfo: {provider: "fakeprovider", loggedIn: true, email: "user@example.com"}
        })});
    });
  });
});
*/
