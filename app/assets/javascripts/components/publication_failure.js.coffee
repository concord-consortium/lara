{div, ul, li, span, a} = ReactFactories

modulejs.define 'components/publication_failure_alert',
['components/publication_ajax_mixin'],
(PublicationAjaxMixin) ->

  createReactClass

    mixins: [PublicationAjaxMixin]

    getInitialState: ->
      scrollTop: 0

    getScrollPosition: ->
      @setState scrollTop: @$window.scrollTop()

    componentDidMount: ->
      @$window = $ window
      @getScrollPosition()
      @$window.on 'scroll', @getScrollPosition

    componentWillUnmount: ->
      @$window.off 'scroll'

    render: ->
      failedPortals = []
      for portal in @state.latest_publication_portals
        if not portal.success
          failedPortals.push portal

      if failedPortals.length > 0
        numPortals = failedPortals.length
        plural = if numPortals > 1 then 's' else ''

        (div {className: 'publication_details'},
          (div {className: 'summary'}, "This item failed to publish to #{numPortals} portal#{plural}:")
          (ul {className: 'details', style: {marginTop: 10}},
            for portal in failedPortals
              debugTitle = "Activity: #{@state.last_publication_hash} => Portal: #{portal.publication_hash}"
              (li {className: 'detail', key: portal.url},
                (span {className: 'detail', title: debugTitle}, portal.domain)
              )
          )
          (div {style: {marginTop: 10}},
            'We will try to publish this again. If it is still failing after a few minutes please email us at '
            (a {href: 'mailto:authoring-help@concord.org'}, 'authoring-help@concord.org')
            ". We recommend not editing further or using this activity through the failing portal#{plural}."
          )
          if @state.scrollTop isnt 0
            topBarStyle =
              position: 'fixed'
              top: 0
              left: 0
              right: 0
              padding: 5
              color: '#fff'
              textAlign: 'center'
              backgroundColor: '#f00'
            (div {style: topBarStyle}, 'Portal publication failure!  More information at the top of this page.')
        )
      else
        null
