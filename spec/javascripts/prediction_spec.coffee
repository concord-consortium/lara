#= require prediction


# TODO: make these available via SpecHelper.js
click_element = (elem) ->
  e2 = jQuery.Event("click")
  e2.target = elem
  elem.trigger(e2)


describe 'Prediction', () ->
  prediction   = null
  fake_saver   = null
  button       = null
  is_final     = null
  answer_text = null
  still_answering = null
  beforeEach () ->
    fake_saver = {
      force_save_item: () ->
        console.log("I was called")
        # nop
    }

    Prediction.saver = fake_saver
    loadFixtures "prediction.html"
    button = $("#prediction_button")
    is_final = $(".is_final")
    still_answering = $(".still_answering")
    answer_text = $("#live-textarea")
    prediction = new Prediction(button)


  describe "a sane testing environment", ->
    it 'has an instance of save_on_change defined', ->
      expect(prediction).toBeDefined()

    it 'has a #prediction_button that is visible', ->
      expect(button).toBeVisible()
    it 'has a spy setup', ->
      expect(Prediction.saver).toBe(fake_saver)
  
  describe "when there is no answer",  ->
    it "the button should be disabled",  ->
      $(document).trigger('no_answer_for', {source: "openresponse"})
      expect(button).toBeDisabled()
    it "the content under is_final should be hidden", ->
      expect(is_final).not.toBeVisible()
    it "the input field should be enabled", ->
      expect(answer_text).toBeVisible()
      expect(answer_text).not.toBeDisabled()

  describe "when the question has an answer",  ->
    beforeEach () ->
      $(document).trigger('answer_for', {source: "openresponse"})
    it "the form should be ready to submit",  ->
      expect(button).not.toBeDisabled()

  describe "clicking the prediction button",  ->
    enable_nav_spy = spyOnEvent(document, 'enable_forward_navigation')
    disable_nav_spy = spyOnEvent(document, 'prevent_forward_navigation')
    beforeEach () ->
      spyOn(fake_saver, "force_save_item")
      prediction.enable_submit_button()
      $("#prediction_button").click()

    it 'should tell fake_saver to force_save_item', ->
      expect(fake_saver.force_save_item).toHaveBeenCalled()

    it 'should disable the form', ->
      expect(button).not.toBeVisible()
      expect(answer_text).toBeDisabled()

    it 'should show the content under answer_is_final', ->
      expect(is_final).toBeVisible()
      expect(still_answering).not.toBeVisible()

    it 'should enable naviagion', ->
      expect(enable_nav_spy).toHaveBeenTriggered()


