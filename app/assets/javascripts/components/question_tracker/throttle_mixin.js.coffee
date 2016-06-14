# Component that includes this mixin needs to define @updateUrl property.
modulejs.define 'components/question_tracker/throttle_mixin', [], () ->

  throttle: (minInterval, func) ->
    if @timeout
      clearTimeout(@timeout)
    @timeout = setTimeout =>
      clearTimeout(@timeout)
      func()
    , minInterval
