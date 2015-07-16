describe "ITSI Editor", () ->

  beforeAll ->
    jasmine.react.itsi =
      captureSave: (component) ->
        saveButton = jasmine.react.findClass component, "ia-save-btn"
        jasmine.react.captureRequest ->
          jasmine.react.click saveButton

      changeTag: (component, tag, newValue) ->
        node = jasmine.react.findTag component, tag
        jasmine.react.change node,
          target:
            name: node.getDOMNode().name
            value: newValue

  describe "alert", ->

    it "renders with alert prop", ->
      alertComponent = jasmine.react.renderComponent "itsi_authoring/alert",
        alert:
          layout: 'test-layout'
          type: 'test-type'
          text: 'test-text'
      div = (jasmine.react.findTag alertComponent, "div").getDOMNode()
      expect(div.className).toBe('ia-alert-test-layout ia-alert-test-type')
      expect(div.innerHTML).toBe('test-text')


    it "renders without alert prop", ->
      alertComponent = jasmine.react.renderComponent "itsi_authoring/alert", {}
      div = (jasmine.react.findTag alertComponent, "div").getDOMNode()
      expect(div.className).toBe('')
      expect(div.innerHTML).toBe('')

  describe "metadata editor", ->

    beforeAll ->
      @props =
        metadata:
          name: "activity name"
          description: "activity description"
          update_url: "fake_update_url"

    it "uses props for default values", ->
      metadataEditor = jasmine.react.renderComponent "itsi_authoring/metadata_editor", @props
      tags = jasmine.react.findTags metadataEditor, ["input", "textarea"]
      expect(tags.input.getDOMNode().value).toBe(@props.metadata.name)
      expect(tags.textarea.getDOMNode().value).toBe(@props.metadata.description)


    it "does not save when no changes are made", ->
      lastAlert = null
      @props.alert = (type, text) ->
        lastAlert = {type: type, text: text}
      metadataEditor = jasmine.react.renderComponent "itsi_authoring/metadata_editor", @props

      jasmine.react.itsi.captureSave metadataEditor

      expect(lastAlert.type).toBe("warn")
      expect(lastAlert.text).toBe("No changes to save")


    it "saves when name changes are made", ->
      metadataEditor = jasmine.react.renderComponent "itsi_authoring/metadata_editor", @props

      jasmine.react.itsi.changeTag metadataEditor, "input", "New activity name"
      request = jasmine.react.itsi.captureSave metadataEditor

      expect(request.url).toBe("fake_update_url")
      expect(request.params).toBe("lightweight_activity%5Bname%5D=New+activity+name&_method=PUT")


    it "saves when description changes are made", ->
      metadataEditor = jasmine.react.renderComponent "itsi_authoring/metadata_editor", @props

      jasmine.react.itsi.changeTag metadataEditor, "textarea", "New activity description"
      request = jasmine.react.itsi.captureSave metadataEditor

      expect(request.url).toBe("fake_update_url")
      expect(request.params).toBe("lightweight_activity%5Bdescription%5D=New+activity+description&_method=PUT")


    it "saves when name and description changes are made", ->
      metadataEditor = jasmine.react.renderComponent "itsi_authoring/metadata_editor", @props

      jasmine.react.itsi.changeTag metadataEditor, "input", "New activity name"
      jasmine.react.itsi.changeTag metadataEditor, "textarea", "New activity description"
      request = jasmine.react.itsi.captureSave metadataEditor

      expect(request.url).toBe("fake_update_url")
      expect(request.params).toBe("lightweight_activity%5Bname%5D=New+activity+name&lightweight_activity%5Bdescription%5D=New+activity+description&_method=PUT")

  describe "section editor element", ->

    it "renders title and visible children when is_hidden is false", ->
      props =
        title: "test title"
        data:
          is_hidden: false
      sectionEditorElement = jasmine.react.renderComponent "itsi_authoring/section_editor_element", props, (React.DOM.div {className: "kids"}, "kids here")
      title = (jasmine.react.findClass sectionEditorElement, "ia-section-editor-title").getDOMNode()
      children = (jasmine.react.findClass sectionEditorElement, "ia-section-editor-elements").getDOMNode()
      kids = (jasmine.react.findClass sectionEditorElement, "kids").getDOMNode()
      expect(title.innerHTML).toBe("test title")
      expect(children.style.display).toBe("block")
      expect(kids.innerHTML).toBe("kids here")


    it "renders invisible children when is_hidden is true", ->
      props =
        title: "test title"
        data:
          is_hidden: true
      sectionEditorElement = jasmine.react.renderComponent "itsi_authoring/section_editor_element", props
      children = (jasmine.react.findClass sectionEditorElement, "ia-section-editor-elements").getDOMNode()
      expect(children.style.display).toBe("none")


    it "toggles children visibility and sends request when select toggled", ->
      props =
        title: "test title"
        toHide: "hidden"
        confirmHide: -> true
        data:
          is_hidden: false
          update_url: "fake_update_url"
      sectionEditorElement = jasmine.react.renderComponent "itsi_authoring/section_editor_element", props

      checkbox = jasmine.react.findTag sectionEditorElement, "input"
      children = (jasmine.react.findClass sectionEditorElement, "ia-section-editor-elements").getDOMNode()

      expect(children.style.display).toBe("block")

      request = jasmine.react.captureRequest ->
        jasmine.react.change checkbox, {"target": {"checked": false}}
      expect(request.url).toBe("fake_update_url.json")
      expect(request.params).toBe("_method=PUT&hidden=1")

      expect(children.style.display).toBe("none")

      request = jasmine.react.captureRequest ->
        jasmine.react.change checkbox, {"target": {"checked": true}}
      expect(request.params).toBe("_method=PUT&hidden=0")

      expect(children.style.display).toBe("block")

    it "toggles does not children visibility when not confirmed", ->
      props =
        title: "test title"
        toHide: "hidden"
        confirmHide: -> false
        data:
          is_hidden: false
          update_url: "fake_update_url"
      sectionEditorElement = jasmine.react.renderComponent "itsi_authoring/section_editor_element", props

      checkbox = jasmine.react.findTag sectionEditorElement, "input"
      children = (jasmine.react.findClass sectionEditorElement, "ia-section-editor-elements").getDOMNode()

      expect(children.style.display).toBe("block")

      request = jasmine.react.captureRequest ->
        jasmine.react.change checkbox, {"target": {"checked": false}}
      expect(request).toBe(undefined)

      expect(children.style.display).toBe("block")

  # NB: all the section editor components share the same form mixin so the save is only tested here
  #     because all the other components use the rich text editor which uses a jquery plugin that
  #     can't be easily tested here.

  describe "drawing response editor", ->

    it "renders default background image", ->
      props =
        title: "test title"
        data:
          is_hidden: false
          bg_url: null
      drawingResponseEditor = jasmine.react.renderComponent "itsi_authoring/drawing_response_editor", props
      defaultBackground = jasmine.react.findClass drawingResponseEditor, "ia-section-default-drawing-tool"
      expect(defaultBackground.getDOMNode().innerHTML).toBe("")


    it "renders custom background image", ->
      props =
        title: "test title"
        data:
          is_hidden: false
          bg_url: "background.jpg"
      drawingResponseEditor = jasmine.react.renderComponent "itsi_authoring/drawing_response_editor", props
      background = jasmine.react.findTag drawingResponseEditor, "img"
      expect(background.getDOMNode().src).toContain("background.jpg")


    it "shows editor when edit is clicked", ->
      props =
        title: "test title"
        data:
          is_hidden: false
          bg_url: "background.jpg"
      drawingResponseEditor = jasmine.react.renderComponent "itsi_authoring/drawing_response_editor", props

      form = jasmine.react.findClass drawingResponseEditor, "ia-section-editor-form"
      expect(form).toBeNull()

      jasmine.react.click (jasmine.react.findClass drawingResponseEditor, "ia-section-editor-edit")
      form = jasmine.react.findClass drawingResponseEditor, "ia-section-editor-form"
      expect(form).toBeDefined()

      input = jasmine.react.findName drawingResponseEditor, "embeddable_image_question[bg_url]"
      expect(input.getDOMNode().value).toBe(props.data.bg_url)


    it "saves background when changed and save is clicked", ->
      props =
        title: "test title"
        data:
          is_hidden: false
          bg_url: "background.jpg"
          update_url: "fake_update_url"
      drawingResponseEditor = jasmine.react.renderComponent "itsi_authoring/drawing_response_editor", props

      jasmine.react.click (jasmine.react.findClass drawingResponseEditor, "ia-section-editor-edit")

      input = jasmine.react.findName drawingResponseEditor, "embeddable_image_question[bg_url]"
      jasmine.react.change input, {target: {value: "new-background.jpg"}}
      expect(input.getDOMNode().value).toBe("new-background.jpg")

      request = jasmine.react.itsi.captureSave drawingResponseEditor
      expect(request.url).toBe("fake_update_url.json")
      expect(request.params).toBe("embeddable_image_question%5Bbg_url%5D=new-background.jpg&_method=PUT")

  describe "model editor", ->

    it "renders no model selected without a name prop", ->
      props =
        title: "test title"
        data:
          is_hidden: false
          url: 'test-model.txt'
          image_url: 'test-model.jpg'
      modelEditor = jasmine.react.renderComponent "itsi_authoring/model_editor", props
      text = jasmine.react.findClass modelEditor, "ia-section-text"
      expect(text.getDOMNode().innerHTML).toBe("No model selected")


    it "renders model name with name prop", ->
      props =
        title: "test title"
        data:
          is_hidden: false
          name: 'test model'
          url: 'test-model.txt'
          image_url: 'test-model.jpg'
      modelEditor = jasmine.react.renderComponent "itsi_authoring/model_editor", props
      text = jasmine.react.findClass modelEditor, "ia-section-text"
      expect(text.getDOMNode().innerHTML).toContain(props.data.name)


    it "loads remote model list when edit clicked", ->
      props =
        title: "test title"
        data:
          is_hidden: false
          name: 'test model'
          url: 'test-model.txt'
          image_url: 'test-model.jpg'
      modelEditor = jasmine.react.renderComponent "itsi_authoring/model_editor", props

      request = jasmine.react.captureRequest ->
        jasmine.react.click (jasmine.react.findClass modelEditor, "ia-section-editor-edit")

      ModelEditorClass = jasmine.react.requireClass "itsi_authoring/model_editor"
      expect(request).toBeDefined()

