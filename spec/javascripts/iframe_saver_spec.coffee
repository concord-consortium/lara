success_response =
  status: 200,
  responseText: '{}'

# this spec is very out of date with the current code
describe 'IFrameSaver', () ->
  fake_phone          = null
  saver               = null
  request             = null

  fake_phone          = jasmine.createSpyObj('iframePhone',['post','addListener'])
  fake_save_indicator = jasmine.createSpyObj('SaveIndicator',['showSaved','showSaving', 'showSaveFailed'])

  beforeEach () ->
    window.IframePhoneManager.getPhone = () ->
      return fake_phone
    loadFixtures "iframe-saver.html"

  getSaver = ->
    new IFrameSaver($('#interactive'), $('#interactive_data_div'), $('.delete_interactive_data'))

  describe "with an interactive in in iframe", ->
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
        expect(fake_phone.post).toHaveBeenCalledWith({ type:'getInteractiveState' });

    describe "save_to_server", () ->
      beforeEach () ->
        jasmine.Ajax.install()
        saver.save_to_server({foo:'bar'})
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
        $("#interactive_data_div").data("save-state", true)
        saver = getSaver()
        # Pretend that communication has been started
        saver.phone_answered()
        request = jasmine.Ajax.requests.mostRecent()
        request.respondWith({
          status: 200,
          responseText: JSON.stringify({"raw_data": JSON.stringify({"interactiveState": 321})})
        })

      afterEach () ->
        jasmine.Ajax.uninstall()

      it "should post 'initInteractive'", () ->
        expect(fake_phone.post).toHaveBeenCalledWith('initInteractive', {
          version: 1,
          error: null,
          mode: 'runtime',
          authoredState: {test: 123},
          interactiveState: {interactiveState: 321},
          globalInteractiveState: null,
          hasLinkedInteractive: false,
          linkedState: null,
          interactiveStateUrl: 'foo/42',
          collaboratorUrls: null
        })

    describe "when state saving is disabled", () ->
      beforeEach () ->
        $("#interactive_data_div").data("save-state", false)
        saver = getSaver()
        # Pretend that communication has been started
        saver.phone_answered()

      it "should post 'initInteractive'", () ->
        expect(fake_phone.post).toHaveBeenCalledWith('initInteractive', {
          version: 1,
          error: null,
          mode: 'runtime',
          authoredState: {test: 123},
          interactiveState: null,
          globalInteractiveState: null,
          hasLinkedInteractive: false,
          linkedState: null,
          interactiveStateUrl: 'foo/42',
          collaboratorUrls: null
        })
