class ArgumentationBlockController
  QUESTION_SEL = '.question'
  QUESTION_FROMS_SEL = QUESTION_SEL + ' form'
  SUBMIT_BTN_SEL = '.ab-submit'
  FEEDBACK_SEL = '.ab-feedback'
  FEEDBACK_ID_SEL = '#feedback_on_'
  FEEDBACK_TEXT_SEL = '.ab-robot-feedback-text'
  DIRTY_MSG_SEL = '.ab-dirty'
  ERROR_MSG_SEL = '.ab-error'
  FEEDBACK_HEADER_SEL = '.ab-feedback-header'
  SUBMISSION_COUNT_SEL = '.ab-submission-count'
  SUBMIT_BTN_PROMPT = '.ab-submit-prompt'
  MAX_ATTEMPTS = 3

  constructor: (argBlockElement) ->
    @$element = $(argBlockElement)
    @$submitBtn = @$element.find(SUBMIT_BTN_SEL)
    @$submitPrompt = @$element.find(SUBMIT_BTN_PROMPT)
    @$submissionCount = @$element.find(SUBMISSION_COUNT_SEL)
    @submissionCount = @$submissionCount.data('submission-count') || 0
    @question = {}
    for q in @$element.find(QUESTION_FROMS_SEL)
      $feedbackEl = $(q).closest(QUESTION_SEL).find(FEEDBACK_SEL)
      isFeedbackDirty = $feedbackEl.data('dirty')
      error = $feedbackEl.data('error')
      @question[@formIDtoAnswerID(q.id)] = {
        # It will be updated by answer_for or no_answer_for event handler.
        answered: false,
        dirty: isFeedbackDirty,
        error: error,
        # 'dirty-data' ensures that question will be always considered as dirty unless it's submitted.
        data: if isFeedbackDirty then 'dirty-data' else $(q).serialize(),
        formElement: q,
        dirtyMsgElement: $feedbackEl.find(DIRTY_MSG_SEL)[0],
        errorMsgElement: $feedbackEl.find(ERROR_MSG_SEL)[0]
      }
    @fbOnFeedback = new FeedbackOnFeedbackController(argBlockElement)
    @registerListeners()

  registerListeners: ->
    # 'answer_for' and 'no_answer_for' events are defined in save-on-change.
    # 'feedback_on_feedback_sent' is defined in FeedbackOnFeedbackController.
    $(document).on 'answer_for', (e, opt) =>
      @updateQuestion(opt.source, true)
      @updateView()
    $(document).on 'no_answer_for', (e, opt) =>
      @updateQuestion(opt.source, false)
      @updateView()
    $(document).on 'feedback_on_feedback_sent', (e, opt) =>
      @updateView()

    @$submitBtn.on 'click', (e) =>
      @submitButtonClicked(e)

  updateQuestion: (id, answered) ->
    q = @question[@formIDtoAnswerID(id)]
    # Undefined means that this question isn't part of the argumentation block.
    return unless q
    q.answered = answered
    q.dirty = q.data != $(q.formElement).serialize()

  submitButtonClicked: (e) ->
    unless @feedbackOnFeedbackIsReady()
      return modalDialog(false, t('ARG_BLOCK.PLEASE_FEEDBACK_ON_FEEDBACK'))
    unless @allQuestionAnswered()
      return modalDialog(false, t('ARG_BLOCK.PLEASE_ANSWER'))
    if !@anyQuestionDirty() && !@anyError()
      return modalDialog(false, t('ARG_BLOCK.ANSWERS_NOT_CHANGED'))

    @$submitBtn.prop('disabled', true)
    @showWaiting()
    @attempts = 0

    @issueRequest()

    @$element.find('.did_try_to_navigate').removeClass('did_try_to_navigate')
    e.preventDefault()
    e.stopPropagation()

  issueRequest: ->
    @attempts += 1
    tryAgain = =>
      setTimeout(=>
        @issueRequest()
      , @attempts * 1000)

    $.ajax(
      type: 'POST',
      url: @$submitBtn.data('href'),
      accepts: 'application/json',
      success: (data) =>
        for id, q of @question
          q.dirty = false # just updated
          q.error = data.feedback_items[id].error
          q.data = $(q).serialize()
        # Try again in case of some errors.
        return tryAgain() if @anyError() && @attempts < MAX_ATTEMPTS

        if @anyError()
          # If we are here, it means that attempts >= MAX_ATTEMPTS. Can't do anything now, just display an error.
          alert(t('ARG_BLOCK.SUBMIT_ERROR'))
        else
          @fbOnFeedback.activate(data.submission_id)
          LoggerUtils.craterResponseLogging(data)

        @submissionCount += 1
        @updateSubmitBtnText()
        @updateView(data.feedback_items)
        @scrollToHeader()
        LoggerUtils.submitArgblockLogging(@$submitBtn.data('page_id'))
        @hideWaiting()
        @$submitBtn.prop('disabled', false)
      error: =>
        return tryAgain() if @attempts < MAX_ATTEMPTS
        alert(t('ARG_BLOCK.SUBMIT_ERROR'))
        # Make sure that user can proceed anyway!
        @enableForwardNavigation()
        @hideWaiting()
        @$submitBtn.prop('disabled', false)
    )

  updateView: (feedbackData, submissionCount) ->
    if feedbackData
      @updateFeedback(feedbackData)
    @updateSubmissionCount()
    @updateSubmitBtn()
    @updateDirtyQuestionMsgs()
    @updateErrorMsgs()
    @updateForwardNavigationBlocking()

  updateSubmissionCount: ->
    @$submissionCount.text(@submissionCount)

  updateSubmitBtn: ->
    if @allQuestionAnswered() && (@anyQuestionDirty() || @anyError()) && @feedbackOnFeedbackIsReady()
      @$submitBtn.removeClass('disabled')
      @hideSubmitPrompt()
    else
      @$submitBtn.addClass('disabled')
      @showSubmitPrompt()

  updateSubmitBtnText: ->
    @$submitBtn[0].value = 'Resubmit'

  showSubmitPrompt: ->
    @$submitPrompt.show()
    unless @feedbackOnFeedbackIsReady()
      @$submitPrompt.html( t('ARG_BLOCK.PLEASE_FEEDBACK_ON_FEEDBACK') )
      return
    unless @allQuestionAnswered()
      @$submitPrompt.html( t('ARG_BLOCK.PLEASE_ANSWER') )
      return
    unless @anyQuestionDirty()
      @$submitPrompt.html( t('ARG_BLOCK.RESUBMIT_OR_MOVE'))

  hideSubmitPrompt: ->
    @$submitPrompt.css('display', 'none')

  showWaiting: ->
    startWaiting 'Please wait while we analyze your responses...','#loading-container'
    $('#modal-container').show()
    $('#loading-container').css('top', $(window).scrollTop() + 200).show()

  hideWaiting: ->
    stopWaiting('#loading-container')
    $('#modal-container').hide()

  updateDirtyQuestionMsgs: ->
    for id, q of @question
      if q.dirty
        $(q.dirtyMsgElement).slideDown()
      else
        $(q.dirtyMsgElement).slideUp()

  updateErrorMsgs: ->
    for id, q of @question
      if q.error
        $(q.errorMsgElement).slideDown()
      else
        $(q.errorMsgElement).slideUp()

  updateForwardNavigationBlocking: ->
    if @allQuestionAnswered() && @noDirtyQuestions() && @feedbackOnFeedbackIsReady()
      @enableForwardNavigation()
    else
      @disableForwardNavigation()

  scrollToHeader: ->
    $('html, body').animate({
      scrollTop: @$element.offset().top - 10
    }, 400)

  enableForwardNavigation: ->
    $(document).trigger('enable_forward_navigation', {source: 'arg-block'})

  disableForwardNavigation: ->
    $(document).trigger('prevent_forward_navigation', {source: 'arg-block', message: t('PLEASE_SUBMIT')})

  updateFeedback: (feedbackData) ->
    anyFeedbackVisible = false
    for id, feedbackItem of feedbackData
      feedbackItem ||= {score: -1, text: ""}
      $feedback = @$element.find(FEEDBACK_ID_SEL + id)
      # Set feedback text.
      $feedback.find(FEEDBACK_TEXT_SEL).html(feedbackItem.text)
      $feedbackScore = $feedback.find(".ab-robot-scale")
      # Clear old score.
      $feedbackScore.removeClass (idx, oldClasses) ->
        (oldClasses.match(/(^|\s)score-\S+/g) || []).join(' ') # matches all score-<val> classes
      # Clear old max-score.
      $feedbackScore.removeClass (idx, oldClasses) ->
        (oldClasses.match(/(^|\s)max-score-\S+/g) || []).join(' ') # matches all max-score-<val> classes
      # Set new score & max-score
      maxScore = feedbackItem.max_score || 6
      $feedbackScore.addClass("max-score-#{maxScore}")
      if feedbackItem.score? && feedbackItem.score >= 0 && feedbackItem.score <= maxScore
        $feedbackScore.addClass("score-#{feedbackItem.score}")
      else
        $feedbackScore.addClass("score--error")
      # Hide feedback if there is no text.
      if feedbackItem.text
        $feedback.slideDown() # show
        anyFeedbackVisible = true
      else
        $feedback.slideUp() # hide

    if anyFeedbackVisible
      @$element.find(FEEDBACK_HEADER_SEL).slideDown()
    else
      @$element.find(FEEDBACK_HEADER_SEL).slideUp()

  allQuestionAnswered: ->
    for id, q of @question
      return false unless q.answered
    true

  anyQuestionDirty: ->
    for id, q of @question
      return true if q.dirty
    false

  anyError: ->
    for id, q of @question
      return true if q.error
    false

  noDirtyQuestions: ->
    !@anyQuestionDirty()

  feedbackOnFeedbackIsReady: ->
    @fbOnFeedback.isReady()

  formIDtoAnswerID: (htmlId) ->
    # E.g. change "edit_embeddable_open_response_answer_240" to "open_response_answer_240"
    htmlId.replace('edit_embeddable_', '')

class FeedbackOnFeedbackController
  FEEDBACK_ON_FEEDBACK_SEL = '.ab-feedback-on-feedback'

  constructor: (argBlockElement) ->
    @$element = $(argBlockElement).find(FEEDBACK_ON_FEEDBACK_SEL)
    @endpointUrl = @$element.data('href')
    @submissionId = @$element.data('submission-id')
    @registerListeners()

  registerListeners: ->
    @$element.find('input').on 'change', =>
      @sendAndDeactivate()

  activate: (submissionId) ->
    @submissionId = submissionId
    @$element.find('input').prop('checked', false)
    @$element.removeClass('did_try_to_navigate')
    @$element.fadeIn()

  deactivate: ->
    # Note that we accept the fact that feedback on feedback failed. We don't want to block page completely.
    @submissionId = null
    @$element.fadeOut()
    $(document).trigger('feedback_on_feedback_sent')

  sendAndDeactivate: ->
    score = @$element.find('input:checked').val()
    $.ajax(
      type: 'POST',
      url: @endpointUrl,
      contentType: 'application/json',
      data: JSON.stringify({
        submission_id: @submissionId,
        score: score
      }),
      complete: =>
        @deactivate()
    )

  isReady: ->
    @submissionId == null || @submissionId == undefined

$(document).ready ->
  $('.arg-block').each ->
    new ArgumentationBlockController(this)
