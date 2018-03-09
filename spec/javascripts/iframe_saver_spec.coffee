success_response =
  status: 200,
  responseText: '{}'

# this spec is very out of date with the current code
describe 'IFrameSaver', () ->
  saver               = null
  request             = null
  iframePhone         = jasmine.mockIframePhone

  beforeEach () ->
    iframePhone.install()
    iframePhone.autoConnect = false
    loadFixtures "iframe-saver.html"

  afterEach () ->
    iframePhone.uninstall()

  getSaver = ->
    new IFrameSaver($('#interactive'), $('#interactive_data_div'), $('.delete_interactive_data'))

  describe "with an interactive in in iframe", ->
    fake_save_indicator = jasmine.createSpyObj('SaveIndicator',['showSaved','showSaving', 'showSaveFailed'])

    beforeEach () ->
      saver = getSaver()
      saver.save_indicator = fake_save_indicator

    describe "a sane testing environment", () ->
      it 'has an instance of IFrameSaver defined', () ->
        expect(saver).toBeDefined()

      it 'has an iframe to work with', () ->
        expect($("#interactive")[0]).toExist()

      it 'has an interactive data element', () ->
        expect($("#interactive_data_div")).toExist()

    describe "constructor called in the correct context", () ->
      it "should have a interactive run state url", () ->
        expect(saver.interactive_run_state_url).toBe("foo/42")

    describe "save", () ->
      beforeEach () ->
        saver.save()

      it "invokes the correct message on the iframePhone", () ->
        expect(iframePhone.messages.findType('getInteractiveState')).toBeTruthy()

    describe "save_learner_state", () ->
      beforeEach () ->
        jasmine.Ajax.install()
        saver.save_learner_state({foo:'bar'})
        request = jasmine.Ajax.requests.mostRecent()
        request.respondWith(success_response)

      afterEach () ->
        jasmine.Ajax.uninstall()

      describe "a successful save", () ->
        it "should display the show saved indicator", () ->
          expect(fake_save_indicator.showSaveFailed).not.toHaveBeenCalled()
          expect(fake_save_indicator.showSaving).toHaveBeenCalled()
          expect(fake_save_indicator.showSaved).toHaveBeenCalled()


  describe "interactive initialization", () ->
    describe "when state saving is enabled", () ->
      beforeEach () ->
        jasmine.Ajax.install()
        $("#interactive_data_div").data("enable-learner-state", true)
        saver = getSaver()
        iframePhone.connect()
        request = jasmine.Ajax.requests.mostRecent()
        request.respondWith({
          status: 200,
          responseText: JSON.stringify({
            "raw_data": JSON.stringify({"interactiveState": 321}),
            "created_at": "2017",
            "updated_at": "2018"
          })
        })

      afterEach () ->
        jasmine.Ajax.uninstall()

      it "should post 'initInteractive'", () ->
        expect(iframePhone.messages.findType('initInteractive').message.content).toEqual({
          version: 1,
          error: null,
          mode: 'runtime',
          authoredState: {test: 123},
          interactiveState: {interactiveState: 321},
          createdAt: '2017'
          updatedAt: '2018'
          globalInteractiveState: null,
          hasLinkedInteractive: false,
          linkedState: null,
          allLinkedStates: [],
          interactiveStateUrl: 'foo/42',
          collaboratorUrls: null,
          classInfoUrl: null,
          interactive: {id: 1, name: "test"},
          authInfo: {provider: "fakeprovider", loggedIn: true, email: "user@example.com"}
        })

    describe "when state saving is disabled", () ->
      beforeEach () ->
        $("#interactive_data_div").data("enable-learner-state", false)
        saver = getSaver()
        iframePhone.connect()

      it "should post 'initInteractive'", () ->
        expect(iframePhone.messages.findType('initInteractive').message.content).toEqual({
          version: 1,
          error: null,
          mode: 'runtime',
          authoredState: {test: 123},
          interactiveState: null,
          interactiveStateCreatedAt: undefined
          interactiveStateUpdatedAt: undefined
          globalInteractiveState: null,
          hasLinkedInteractive: false,
          linkedState: null,
          allLinkedStates: [],
          interactiveStateUrl: 'foo/42',
          collaboratorUrls: null,
          classInfoUrl: null,
          interactive: {id: 1, name: "test"},
          authInfo: {provider: "fakeprovider", loggedIn: true, email: "user@example.com"}
        })
