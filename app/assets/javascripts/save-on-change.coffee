
class @SaveOnChange
  changeInterval: 200  # Fire change and blur events almost instantly.
  keyUpinterval:  2000 # Fire keyup events with a larger delay
  constructor: (@$form, @page) ->
    @scheduled_job      = null
    @previous_value     = null
    @setupEvents()

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
      error: (jqxhr, status, error) =>
        @page.failed(@)
    })

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
    @dirty_forms[form] = form;

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
