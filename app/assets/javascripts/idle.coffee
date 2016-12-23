# adapted from https://github.com/shawnmclean/Idle.js/blob/master/src/idle.coffee
#
#  1) Added jQuery
#  2) Cleaned up some of the CoffeeScript
#

window.IdleCheck = class IdleCheck

  constructor: (options) ->
    @isAway = false
    @awayTimeout = 3000
    @awayTimestamp = 0
    @awayTimer = null

    @onAway = null
    @onAwayBack = null
    @onVisible = null
    @onHidden = null

    @listener = null

    if(options)
      @awayTimeout = parseInt(options.awayTimeout, 10) or @awayTimeout
      @onAway = options.onAway
      @onAwayBack = options.onAwayBack
      @onVisible = options.onVisible
      @onHidden = options.onHidden

    activeMethod = => @onActive()

    $window = $ window
    $window.on 'click', activeMethod
    $window.on 'mousemove', activeMethod
    $window.on 'mouseenter', activeMethod
    $window.on 'keydown', activeMethod
    $window.on 'scroll', activeMethod
    $window.on 'mousewheel', activeMethod
    $window.on 'touchmove', activeMethod
    $window.on 'touchstart', activeMethod

    @listener = => @handleVisibilityChange()
    $document = $ document
    $document.on "visibilitychange", @listener
    $document.on "webkitvisibilitychange", @listener
    $document.on "msvisibilitychange", @listener

    @start()

  onActive: () ->
    now = new Date().getTime()
    @awayTimestamp = now + @awayTimeout
    if @isAway
      @onAwayBack?(now - @awayAt)
      @start()
    @isAway = false
    true

  start: () ->
    clearTimeout @awayTimer
    @awayTimestamp = new Date().getTime() + @awayTimeout
    @awayTimer = setTimeout (=> @checkAway()), @awayTimeout + 100
    @

  stop: () ->
    clearTimeout @awayTimer
    if @listener
      $document = $ document
      $document.off "visibilitychange", @listener
      $document.off "webkitvisibilitychange", @listener
      $document.off "msvisibilitychange", @listener
      @listener = null
    @

  setAwayTimeout: (ms) ->
    @awayTimeout = parseInt ms, 10
    @

  checkAway: () ->
    t = new Date().getTime()
    if t < @awayTimestamp
      @isAway = false
      @awayTimer = setTimeout (=> @checkAway()), @awayTimestamp - t + 100
    else
      clearTimeout @awayTimer
      @isAway = true
      @awayAt = t
      @onAway?()

  handleVisibilityChange: () ->
    if document.hidden || document.msHidden || document.webkitHidden
      @onHidden?()
    else
      @onVisible?()

