#= require save-on-change
#= require mock-ajax


# TODO: Figure out how to
send_char = (elem, character) ->
  char_code = character.charCodeAt(0)
  e2 = jQuery.Event("keyup", {'keyCode': char_code })
  e2.which = char_code
  e2.keyCode = char_code
  e2.target = elem
  elem.trigger(e2)

enter_text_area = (elem, text) ->
  for character in text
    send_char(elem, character)
  elem.text(text)

click_element = (elem) ->
  e2 = jQuery.Event("click")
  e2.target = elem
  elem.trigger(e2)

describe 'SaveOnChange', () ->
  save_on_change   = null

  beforeEach () ->
    loadFixtures "save-on-change.html"
    jasmine.Ajax.useMock()
    save_on_change = new SaveOnChange($("#live-textarea"));

  describe "a sane testing environment", () ->
    it 'has an instance of save_on_change defined', () ->
      expect(save_on_change).toBeDefined()

    it 'has a dom element with a textarea', () ->
      expect($("#live-textarea")).toExist()


  describe "entering text into a live_submit textarea", () ->
    text_to_type = "this is a test"

    it 'should send an ajax request with the current value', ->
      runs ->
        enter_text_area($("#live-textarea"),text_to_type)
        expect($("#live-textarea").text()).toBe text_to_type
      waits 700 #wait-interval-s
      runs ->
        request = mostRecentAjaxRequest();
        expect(request.url).toBe('/embeddable/open_response_answers/165');
        expect(request.method).toBe('POST');
        expect(request.params).toEqual('embeddable_open_response_answer%5Banswer_text%5D=this+is+a+test');

  describe "clicking on a live multiple choice button", () ->
    beforeEach () ->
      new SaveOnChange($("#answer_a"));
      new SaveOnChange($("#answer_b"));
      new SaveOnChange($("#answer_c"));
    it 'should send an ajax request with the current of the selected checkbox', ->
      runs ->
        expect($("#answer_b")).toHaveProp('checked', false);
        click_element($("#answer_b"))
      runs ->
        expect($("#answer_b")).toHaveProp('checked', true);
        request = mostRecentAjaxRequest();
        expect(request.url).toBe('/embeddable/multiple_choice_answers/255');
        expect(request.method).toBe('POST');
        expect(request.params).toEqual('mc_answer%5Banswers%5D=b');
    it "shouldn't get request more than once", ->


