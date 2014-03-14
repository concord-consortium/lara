#= require iframe-saver
#= require save-indicator
#= require save-on-change
#= require mock-ajax


# TODO: make these available via SpecHelper.js
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

select_element = (elem,val) ->
  elem.val(val)
  e2 = jQuery.Event("change")
  e2.target = elem
  elem.trigger(e2)

ajax_matching = (url, params, delay=2100, method="POST") ->
  waits delay
  runs ->
    request = mostRecentAjaxRequest()
    expect(request.url).toBe(url)
    expect(request.method).toBe(method)
    expect(request.params).toEqual(params)

describe 'SaveOnChange', () ->
  save_on_change   = null

  beforeEach () ->
    loadFixtures "save-on-change.html"
    jasmine.Ajax.useMock()
    SaveOnChange.keyUpinterval = 300 # speed things up for test
    page = new SaveOnChangePage()
    save_on_change = new SaveOnChange($("#openresponse"), page)

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
      runs ->
        ajax_matching(
          '/embeddable/open_response_answers/165',
          'embeddable_open_response_answer%5Banswer_text%5D=this+is+a+test'
        )


  describe "clicking on a live multiple choice button", () ->
    beforeEach () ->
      page = new SaveOnChangePage()
      new SaveOnChange($("#multiplechoice"),page)

    it 'should send an ajax request with the current of the selected checkbox', () ->
      runs ->
        expect($("#answer_b")).toHaveProp('checked', false)
        click_element($("#answer_b"))
      runs ->
        expect($("#answer_b")).toHaveProp('checked', true)
        ajax_matching(
          '/embeddable/multiple_choice_answers/255',
          'mc_answer%5Banswers%5D=b'
        )

    it 'should send an ajax request even when the same answer has been sent before', () ->
      runs ->
        click_element($("#answer_b"))
        click_element($("#answer_a"))
        click_element($("#answer_b"))

      runs ->
        expect($("#answer_b")).toHaveProp('checked', true)
        ajax_matching(
          '/embeddable/multiple_choice_answers/255',
          'mc_answer%5Banswers%5D=b'
        )

  describe "selecting something from a pulldown list", () ->
    beforeEach () ->
      page = new SaveOnChangePage()
      new SaveOnChange($("#pulldown"), page)

    it 'should send an ajax request with the current pulldown selection', ->
      runs ->
        expect($("#select").val()).toBe("")
        select_element($("#select"),'select_b')

      runs ->
        ajax_matching(
          '/embeddable/multiple_choice_answers/279',
          'pulldown%5Banswers%5D=select_b'
        )

  describe "page noticing dirty items", () ->
    page     = null
    pulldown = null
    beforeEach () ->
      page     = new SaveOnChangePage()
      pulldown = new SaveOnChange($("#pulldown"), page)

    it 'should notice when items get dirty or save', ->
      spyOn(pulldown, 'saveNow');
      runs ->
        expect($("#select").val()).toBe("")
        select_element($("#select"),'select_b')
        click_element($("#navigationlink"))
        expect(pulldown.saveNow).toHaveBeenCalled();



