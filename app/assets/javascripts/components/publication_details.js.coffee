{div, ul, li, span, a} = ReactFactories

modulejs.define 'components/publication_details',
['components/publication_ajax_mixin'],
(PublicationAjaxMixin) ->

  createReactClass

    mixins: [PublicationAjaxMixin]

    render: ->
      numPortals = @state.latest_publication_portals.length
      plural = if numPortals > 1 then 's' else ''

      (div {className: 'publication_details'},
        (div {className: 'summary'},
          if numPortals > 0
            "This item has been published to #{numPortals} portal#{plural}. Any changes will automatically be published to the portal#{plural} below."
          else
            "This item is not published to any of the portals. Click on the publish button to publish this item."
        )
        (ul {className: 'details'},
          for portal in @state.latest_publication_portals
            debugTitle = "Activity: #{@state.last_publication_hash} => Portal: #{portal.publication_hash}"
            (li {className: 'detail', key: portal.url},
              (span {className: 'detail'}, portal.domain)
              (span {className: 'detail'}, " : (#{portal.success_count} time#{if portal.success_count is 1 then '' else 's'}) - ")
              (span {className: 'detail'}, portal.date)
              if portal.success
                message = if @state.last_publication_hash is null or @state.last_publication_hash is portal.publication_hash then 'published' else 'publishing'
                (span {className: 'message success-message', title: debugTitle}, message)
              else
                (span {className: 'message error-message', title: debugTitle}, 'not published!')
            )
        )
        (a {href: @props.publicationDetails.publish_url, className: 'btn btn-primary', 'data-remote': true, 'data-testid': 'publish-to-other-portals-btn'}, 'Publish to Other Portals')
      )