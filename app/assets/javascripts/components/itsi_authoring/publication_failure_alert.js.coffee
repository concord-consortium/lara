{div, ul, li, span, a} = React.DOM

modulejs.define 'components/itsi_authoring/publication_failure_alert',
['components/itsi_authoring/publication_ajax_mixin'],
(PublicationAjaxMixin) ->

  React.createClass

    mixins: [PublicationAjaxMixin]

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
        )
      else
        null

