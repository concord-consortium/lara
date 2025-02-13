modulejs.define 'components/publication_ajax_mixin', ->

  getInitialState: ->
    last_publication_hash: @props.publicationDetails.last_publication_hash
    latest_publication_portals: @props.publicationDetails.latest_publication_portals
    polling: false

  componentDidMount: ->
    @poller = setInterval @pollForChanges, 5000

  componentWillUnmount: ->
    clearInterval @poller

  pollForChanges: ->
    $.ajax
      url: @props.publicationDetails.poll_url
      type: 'GET',
      success: (data) =>
        if data
          @setState
            last_publication_hash: data.last_publication_hash
            latest_publication_portals: data.latest_publication_portals