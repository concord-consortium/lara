unless Array::filter
  Array::filter = (callback) ->
    element for element in this when callback(element)

class @AnswerChecker
  @FieldNames = [
    "embeddable_open_response_answer[answer_text]"
    "embeddable_multiple_choice_answer[answers]"
    "embeddable_multiple_choice_answer[answers][]"
    "embeddable_image_question_answer[annotation]"
    "embeddable_image_question_answer[image_url]"
    "embeddable_image_question_answer[annotated_image_url]"
    "embeddable_image_question_answer[answer_text]"
  ]
  constructor: (@$form) ->
    @data = []

  is_answered: () ->
    @data = @$form.serializeArray()
    @data = @data.filter (obj) ->
      obj.name in AnswerChecker.FieldNames
    @data = @data.filter (obj) ->
      !!obj.value

    # we need to check answers when the page
    # loads too... (?)
    @data.length > 0

class @SaveOnChange
  changeInterval: 200  # Fire change and blur events almost instantly.
  keyUpinterval:  2000 # Fire keyup events with a larger delay

  constructor: (@$form, @page) ->
    @scheduled_job      = null
    @previous_value     = null
    @setupEvents()
    # don't send events until the doc
    # is ready
    $(document).ready () =>
      @checker = new AnswerChecker(@$form)
      @check_for_answer()


  setupEvents: ->
    @$form.find('input,textarea,select').on 'change blur', (e) =>
      @schedule(@changeInterval)
    @$form.find('input,textarea').on 'keyup',  (e) =>
      @schedule(@keyUpinterval)

  saveElement:(async = true) ->
    data = @$form.serialize()
    @page.saving()
    $.ajax({
      type: "POST",
      async: async,
      url: @$form.attr( 'action' ),
      data: @$form.serialize(),
      success: (response) =>
        @previous_value = data
        @page.saved(@)
        @dirty = false
        @check_for_answer()
      error: (jqxhr, status, error) =>
        @page.failed(@)
    })

  check_for_answer: ->
    if @checker.is_answered()
      @announce_data()
    else
      @announce_no_data()

  announce_data: ->
    console.log "we have data"
    $(document).trigger("answer_for", {source: @$form.attr('id')})

  announce_no_data: ->
    console.log "we have no data"
    $(document).trigger("no_answer_for", {source: @$form.attr('id')})

  saveNow: ->
    @unschedule()
    @saveElement(false)

  # remove events scheduled for elem
  unschedule: () ->
    clearTimeout(@scheduled_job) if @scheduled_job
    @scheduled_job = null

  schedule:  (interval) ->
    @unschedule() # remove any existing events
    dirty = (@previous_value != @$form.serialize())
    if dirty
      @page.mark_dirty(this)
      action = () =>
        @saveElement()
      @scheduled_job = setTimeout(action, interval)

class @ForwardBlocker
  constructor: (@binding=$(document)) ->
    @blockers = []
    @blocking = false
    @bind_events()

  bind_events: ->
    @binding.bind 'prevent_forward_navigation', (e,opts) =>
      @prevent_forward_navigation_for(opts.source)
    @binding.bind 'enable_forward_navigation', (e,opts) =>
      @enable_forward_navigation_for(opts.source)
    @binding.bind 'navigate_away', (e,opts) =>
      @navigate_away(opts.click_element)

  prevent_forward_navigation_for: (blocker) ->
    if blocker not in @blockers
      @blockers.push blocker
      @update_display()

  enable_forward_navigation_for: (blocker) ->
    index = @blockers.indexOf(blocker)
    if index > -1
      @blockers.splice(index,1)
      @update_display()

  navigate_away: (click_element) ->
    location = click_element.href
    console.log "asked to navigate away by #{click_element}"
    console.log "asked to navigate to #{location}"
    unless @block_for_element(click_element)
      window.location = location

  update_display: () ->
    num_blockers = @blockers.length
    if num_blockers > 0
      $('.forward_nav').addClass('disabled')
      @blocking = true
    else
      $('.forward_nav').removeClass('disabled')
      @blocking = false

   block_for_element: (elm) ->
     debugger
     return false unless $(elm).hasClass('forward_nav')
     return @blocking

class @SaveOnChangePage
  constructor: (@blocker = new ForwardBlocker()) ->
    @save_indicator = SaveIndicator.instance()
    @intercept_navigation()
    @forms = []
    @prevent_forward_navigation_count = 0
    if $('.live_submit').length
      $('.live_submit').each (i,e) =>
        @forms.push(new SaveOnChange($(e),@))
    @dirty_forms = {}

  intercept_navigation: ->
    $("a").not('.colorbox').not('[target]').on 'click', (e) =>
      e.preventDefault()
      @click_element   = e.currentTarget
      @force_save_dirty()

  saving: (form) ->
    @save_indicator.showSaving()

  saved: (form) ->
    @save_indicator.showSaved()
    @mark_clean(form)

  failed: (form) ->
    @save_indicator.showSaveFailed()

  mark_dirty: (form) ->
    @dirty_forms[form] = form

  navigate_away: ->
    if @click_element
      args = {click_element: @click_element}
      $(document).trigger('navigate_away', args)

  mark_clean: (form) ->
    delete @dirty_forms[form]

  force_save_item: ($form_jq) ->
    for f in @forms
      do (f) ->
        if f.$form[0] ==$form_jq[0]
          f.saveElement(false)

  force_save_dirty: ()->
    for item, value of @dirty_forms
      value.saveNow()
    waiting_on = IFrameSaver.instances.length
    found      = 0
    if waiting_on > 0
      for count, saver of IFrameSaver.instances
        saver.save =>
          found = found + 1
          if (found + 1 ) >= waiting_on
            @navigate_away()
    else
      @navigate_away()


$(document).ready ->
  window.SaveOnChangePage = SaveOnChangePage
  window.SaveOnChange     = SaveOnChange
  SaveOnChangePage.instance = new SaveOnChangePage()
