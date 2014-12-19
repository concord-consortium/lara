unless Array::filter
  Array::filter = (callback) ->
    element for element in this when callback(element)

class @CompleteChecker
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

  filtered_data: (array) ->
    array.filter(obj) ->
      obj.name in CompleteChecker.FieldNames

  mark_submit_clean: () ->
    @$form.find("i.required").removeClass("submit_required")

  mark_submit_required: () ->
    @$form.find("i.required").addClass("submit_required")

  mark_form_element_clean: (obj) ->
    @$form.find("[name='#{obj.name}']").removeClass("missing_required")

  mark_form_element_missing_required: (obj) ->
    @$form.find("[name='#{obj.name}']").addClass("missing_required")

  mark_form_missing_required: () ->
    unless @$form.hasClass("ignore_missing")
      @$form.addClass("missing_required")

  mark_form_clean: () ->
    @$form.removeClass("missing_required")

  require_is_final: () ->
    $required = @$form.find("input.hidden_is_final")
    if $required.length > 0
      completed = $required.val() == "t" || $required.val() == "1" || $required.val() == 1
      if not completed
        @mark_submit_required()

  is_answered: () ->
    @mark_form_clean()
    hidden_final = @$form.find("input.hidden_is_final")
    return true unless hidden_final.length > 0
    data = @$form.serializeArray()
    @data = data.filter (obj) ->
      obj.name in CompleteChecker.FieldNames

    if @data.length == 0 # multiple choices
      @mark_form_missing_required()
      return false

    @mark_form_element_clean(obj) for obj in @data
    @unasnwered = @data.filter (obj) ->
      !obj.value

    if @unasnwered.length > 0
      @mark_form_element_missing_required(obj) for obj in @unasnwered
      @mark_form_missing_required()
      return false

    @require_is_final()
    return true


class @SaveOnChange
  changeInterval: 200  # Fire change and blur events almost instantly.
  keyUpinterval:  2000 # Fire keyup events with a larger delay

  constructor: (@$form, @page) ->
    @scheduled_job      = null
    @previous_value     = null
    @setupEvents()
    @setupManualSubmitSupport()
    # don't send events until the doc
    # is ready
    $(document).ready () =>
      @checker = new CompleteChecker(@$form)
      @check_for_answer()

  setupEvents: ->
    @$form.find('input,textarea,select').on 'change blur', (e) =>
      @schedule(@changeInterval)
    @$form.find('input,textarea').on 'keyup',  (e) =>
      @schedule(@keyUpinterval)

  setupManualSubmitSupport: ->
    # We can manually call form.submit() and everything should be handled as expected:
    # - saving notification is displayed
    # - answer is announced ('answer_for' and 'no_answer_for' events)
    previous_data = null
    @$form
      .on('submit', =>
        # This happens prior to the actual submission
        previous_data = @$form.serialize()
        @page.saving()
      ).on('ajax:success', (e, data, status, xhr) =>
        @save_success(previous_data)
      ).on('ajax:error', (e, xhr, status, error) =>
        @save_error()
      )

  saveElement: (async = true) ->
    data = @$form.serialize()
    @page.saving()
    $.ajax({
      type: "POST",
      async: async,
      url: @$form.attr( 'action' ),
      data: @$form.serialize(),
      success: (response) =>
        @save_success(data)
      error: (jqxhr, status, error) =>
        @save_error()
    })

  save_success: (previous_data) ->
    @previous_value = previous_data
    @page.saved(@)
    @dirty = false
    @check_for_answer()

  save_error: ->
    @page.failed(@)

  check_for_answer: ->
    if @checker.is_answered()
      @announce_data()
    else
      @announce_no_data()

  announce_data: ->
    $(document).trigger("answer_for", {source: @$form.attr('id')})

  announce_no_data: ->
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
    if @block_for_element(click_element)
      $('.question').addClass('did_try_to_navigate')
      modalDialog(false, t('PLEASE_SUBMIT'))
    else
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
    $("a").not('.colorbox').not('[target]').not("#menu-trigger").not("[data_trigger_save=false]").on 'click', (e) =>
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
    if (typeof IFrameSaver == "undefined")
      @navigate_away()
      return

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
