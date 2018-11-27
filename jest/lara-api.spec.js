// Manually setup dependencies for LARA API... For now, it's only jQuery and jQuery UI.
// It's still possible, I'm not sure if it's possible long term. If it's only an interim solution,
// a good side effect is that it documents dependencies for given module. It might get too annoying though.
// Writing tests in Jest is awesome, but it requires proper setup of the JS code and dependencies management.
const $ = require("../app/assets/javascripts/jquery-2.2.4");
global.$ = $;
global.jQuery = $;
require("../app/assets/javascripts/jquery-ui-1.12.1");

require("../app/assets/javascripts/sidebar")

require("../app/assets/javascripts/lara-api");

describe("LARA API", () => {
  it("should exist", () => {
    expect(LARA).toBeDefined();
  })

  describe("#addPopup", () => {
    it("should exist", () => {
      expect(LARA.addPopup).toBeDefined();
    })

    it("should handle basic options and create DOM element with correct content", () => {
      const content = $("<div id='test-dialog'>Test dialog</div>")[0]
      LARA.addPopup({
        content,
        title: "Test title"
      });
      expect($("body").find("#test-dialog").length).toEqual(1);
      expect($("body").text()).toEqual(expect.stringContaining("Test dialog"));
      expect($("body").text()).toEqual(expect.stringContaining("Test title"));
    })

    describe("when user closes a dialog", () => {
      it("it removes container from the DOM if removeOnClose is equal to true and calls onRemove", () => {
        const content = $("<div id='test-dialog'>Test dialog</div>")[0]
        const onRemoveCallback = jest.fn()
        LARA.addPopup({ content, removeOnClose: true, onRemove: onRemoveCallback });
        expect($("body").find("#test-dialog").length).toEqual(1);
        $(".ui-dialog-titlebar-close").click();
        expect($("body").find("#test-dialog").length).toEqual(0);
        expect(onRemoveCallback).toHaveBeenCalledTimes(1);
      })

      it("it doesn't remove container from the DOM if removeOnClose is equal to false", () => {
        const content = $("<div id='test-dialog'>Test dialog</div>")[0]
        const onRemoveCallback = jest.fn()
        LARA.addPopup({ content, removeOnClose: false, onRemove: onRemoveCallback });
        expect($("body").find("#test-dialog").length).toEqual(1);
        $(".ui-dialog-titlebar-close").click();
        expect($("body").find("#test-dialog").length).toEqual(1);
        expect(onRemoveCallback).toHaveBeenCalledTimes(0);
      })

      it("it calls onClose callback", () => {
        const content = $("<div id='test-dialog'>Test dialog</div>")[0]
        const onCloseCallback = jest.fn()
        LARA.addPopup({
          content,
          onClose: onCloseCallback
        });
        $(".ui-dialog-titlebar-close").click();
        expect(onCloseCallback).toHaveBeenCalledTimes(1);
      })
    })
  })

  describe("#addSidebar", () => {
    it("should exist", () => {
      expect(LARA.addSidebar).toBeDefined();
    })

    it("should handle basic options and create DOM element with correct content", () => {
      LARA.addSidebar({
        content: $("<div id='test-sidebar'>Test sidebar</div>")[0],
        icon: $("<div id='test-icon'>")[0],
        handle: "Test handle",
        titleBar: "Test title bar"
      });
      expect($("body").find("#test-sidebar").length).toEqual(1);
      expect($("body").find("#test-icon").length).toEqual(1);
      expect($("body").text()).toEqual(expect.stringContaining("Test sidebar"));
      expect($("body").text()).toEqual(expect.stringContaining("Test handle"));
      expect($("body").text()).toEqual(expect.stringContaining("Test title bar"));
    })

    it("returns a simple controller that can be used to open or close sidebar", () => {
      const onOpenCallback = jest.fn();
      const onCloseCallback = jest.fn();
      const controller = LARA.addSidebar({
        content: $("<div id='test-sidebar'>Test sidebar</div>")[0],
        onOpen: onOpenCallback,
        onClose: onCloseCallback
      });
      expect(controller.open).toBeDefined();
      expect(controller.close).toBeDefined();

      controller.open();
      controller.open(); // nothing should happen, already open
      expect(onOpenCallback).toHaveBeenCalledTimes(1);

      controller.close();
      controller.close(); // nothing should happen, already closed
      expect(onCloseCallback).toHaveBeenCalledTimes(1);
    })

    describe("when user opens a sidebar", () => {
      it("it calls onOpen callback and main element gets expanded", () => {
        const onOpenCallback = jest.fn();
        LARA.addSidebar({
          content: $("<div id='test-sidebar'>Test sidebar</div>")[0],
          onOpen: onOpenCallback
        });
        $(".sidebar-hdr").click();
        expect(onOpenCallback).toHaveBeenCalledTimes(1);
        expect($(".sidebar-mod.expanded").length).toEqual(1);
      })
    })

    describe("when user closes a sidebar", () => {
      it("it calls onClose callback", () => {
        const onCloseCallback = jest.fn();
        LARA.addSidebar({
          content: $("<div id='test-sidebar'>Test sidebar</div>")[0],
          onClose: onCloseCallback
        });
        $(".sidebar-hdr").click(); // open
        $(".sidebar-hdr").click(); // close
        expect(onCloseCallback).toHaveBeenCalledTimes(1);
      })
    })
  })

  describe("#saveLearnerPluginState", () => {
    const plugin = jest.fn()
    const state = JSON.toString({this: "is a test"});

    let pluginFunction = jest.fn((plugin,state) => Promise.resolve(state))
    beforeEach(()=> global.Plugins= { saveLearnerPluginState: pluginFunction})

    it("should exist", () => {
      expect(LARA.saveLearnerPluginState).toBeDefined();
    })

    it("should deligate the function to Plugins", () => {
      expect.assertions(2);
      return LARA.saveLearnerPluginState(plugin, state)
        .then((d) => {
          expect(d).toMatch(state)
          expect(pluginFunction).toHaveBeenCalledTimes(1)
      })
    })

    describe("when saving fails", () => {
      let pluginFunction = jest.fn((plugin,state) => Promise.reject("fail"))
      beforeEach(()=> global.Plugins= { saveLearnerPluginState: pluginFunction})
      it("should throw an exception", () => {
        expect.assertions(2);
        return LARA.saveLearnerPluginState(plugin, state)
          .catch((e) => {
            expect(e).toMatch("fail")
            expect(pluginFunction).toHaveBeenCalledTimes(1)
          })
      })
    })
  })

  describe("#registerPlugin", () => {
    const plugin = jest.fn()
    const label  = 'fakePlugin'

    let pluginFunction = jest.fn((plugin,state) => true)
    beforeEach(()=> global.Plugins= { registerPlugin: pluginFunction})
    it("should exist", () => {
      expect(LARA.registerPlugin).toBeDefined();
    })

    it("should deligate to Plugin", () => {
      expect(LARA.registerPlugin(label, plugin)).toBeTruthy()
      expect(pluginFunction).toHaveBeenCalledTimes(1)
    })

  })
})
