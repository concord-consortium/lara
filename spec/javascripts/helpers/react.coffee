TestUtils = React.addons.TestUtils

jasmine.react =
  requireClass: (name) ->
    modulejs.require "components/#{name}"

  requireComponent: (name) ->
    React.createFactory modulejs.require "components/#{name}"

  renderComponent: (path, props, children = null) ->
    TestUtils.renderIntoDocument ((jasmine.react.requireComponent path) props, children)

  findTag: (component, tag) ->
    try
      TestUtils.findRenderedDOMComponentWithTag component, tag
    catch
      null

  findTags: (component, tags) ->
    results = {}
    for tag in tags
      results[tag] = jasmine.react.findTag component, tag
    results

  findClass: (component, className) ->
    try
      TestUtils.findRenderedDOMComponentWithClass component, className
    catch
      null

  findComponent: (component, childComponent) ->
    type = jasmine.react.requireClass childComponent
    try
      TestUtils.findRenderedComponentWithType component, type
    catch
      null

  allWhere: (component, where) ->
    all = TestUtils.findAllInRenderedTree component, where

  findWhere: (component, where) ->
    (jasmine.react.allWhere component, where)?[0] or null

  allWhereDOMNode: (component, where) ->
    all = TestUtils.findAllInRenderedTree component, (test) -> where test.getDOMNode()

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
    React.addons.TestUtils.Simulate.click node

  change: (node, attrs) ->
    React.addons.TestUtils.Simulate.change node, attrs
