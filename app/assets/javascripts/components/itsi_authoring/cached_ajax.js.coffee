# Simple cache of AJAX requests based on URLs.
modulejs.define 'components/itsi_authoring/cached_ajax', ->
  cache = {}

  (options) ->
    if cache[options.url]
      options.success(cache[options.url]) if options.success?
      return

    $.ajax
      url: options.url
      dataType: 'json'
      success: (data) ->
        cache[options.url] = data
        options.success(data) if options.success?
      error: options.error
      complete: options.complete
