$ ->
  # abort if not on authoring page
  authoringPages = [
    /\/activities\/new/
    /\/activities\/(\d+)\/edit/
    /\/activities\/(\d+)\/pages\/(\d+)\/edit/
  ]
  inAuthoringPages = (true for regex in authoringPages when regex.test(window.location.pathname)).length > 0

  if inAuthoringPages
    blockerId = 'edit-blocker'
    $body = $ document.body

    blockerHTML = $ [
      '<div id="', blockerId, '" >',
        '<div style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; background-color: #000; opacity: 0.25"></div>',
        '<div style="position: absolute; top: 25%; left: 25%; right: 25%; background-color: #fff; text-align: center; font-size: 24px; line-height: 2em; padding: 30px;">',
          'Your login session has timed out.  Reload this page to log back in and continue editing.'
        '</div>',
      '</div>'
    ].join('')

    blockEdits = (block) ->
      $blocker = $body.find '#' + blockerId
      hasBlocker = $blocker.length > 0

      if block and !hasBlocker
        $body.append blockerHTML
      else if !block and hasBlocker
        $blocker.remove()

    userCheck = ->
      onSuccess = (result) ->
        haveUser = result?.user?
        blockEdits !haveUser
      onFail = ->
        blockEdits true
      $.getJSON('/api/v1/user_check', onSuccess).fail(onFail)

    idleCheck = new IdleCheck
      onAwayBack: -> userCheck()
      onVisible: -> userCheck()
      awayTimeout: 10000

