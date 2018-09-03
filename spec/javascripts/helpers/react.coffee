jasmine.react =
  requireClass: (name) ->
    modulejs.require "components/#{name}"

  requireComponent: (name) ->
    React.createFactory modulejs.require "components/#{name}"

  renderComponent: (path, props, children = null) ->
    ReactTestUtils.renderIntoDocument ((jasmine.react.requireComponent path) props, children)

  findTag: (component, tag) ->
    try
      ReactTestUtils.findRenderedDOMComponentWithTag component, tag
    catch
      null

  findTags: (component, tags) ->
    results = {}
    for tag in tags
      results[tag] = jasmine.react.findTag component, tag
    results

  findClass: (component, className) ->
    try
      ReactTestUtils.findRenderedDOMComponentWithClass component, className
    catch
      null

  findComponent: (component, childComponent) ->
    type = jasmine.react.requireClass childComponent
    try
      ReactTestUtils.findRenderedComponentWithType component, type
    catch
      null

  allWhere: (component, where) ->
    all = ReactTestUtils.findAllInRenderedTree component, where

  findWhere: (component, where) ->
    (jasmine.react.allWhere component, where)?[0] or null

  allWhereDOMNode: (component, where) ->
    all = ReactTestUtils.findAllInRenderedTree component, (test) -> where ReactDOM.findDOMNode(test)

  findWhereDOMNode: (component, where) ->
    (jasmine.react.allWhereDOMNode component, where)?[0] or null

  findName: (component, name) ->
    jasmine.react.findWhereDOMNode component, (node) -> node.name is name

  captureRequest: (callback) ->
    jasmine.Ajax.install()
    callback()
    request = jasmine.Ajax.requests.mostRecent()
    jasmine.Ajax.uninstall()
    request

  click: (node) ->
    ReactTestUtils.Simulate.click node

  change: (node, attrs) ->
    ReactTestUtils.Simulate.change node, attrs
