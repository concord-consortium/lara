// Manually setup dependencies for LARA API... For now, it's only jQuery and jQuery UI.
// It's still possible, I'm not sure if it's possible long term. If it's only an interim solution,
// a good side effect is that it documents dependencies for given module. It might get too annoying though.
// Writing tests in Jest is awesome, but it requires proper setup of the JS code and dependencies management.
const $ = require("../app/assets/javascripts/jquery-2.2.4");
global.$ = $;
global.jQuery = $;
require("../app/assets/javascripts/jquery-ui-1.12.1");

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

  describe("#saveLearnerPluginState", () => {
    const plugin = jest.fn()
    const state = JSON.toString({this: "is a test"});

    it("should exist", () => {
      expect(LARA.saveLearnerPluginState).toBeDefined();
    })

    describe("when the global PluginApiis NOT available", () => {
      it("should return a promise with a rejection", () => {
        expect.assertions(1);
        return LARA.saveLearnerPluginState(plugin, state)
          .then((d) => {throw new Error("learner state should not be saved")})
          .catch((e) => expect(e).toMatch("fail"))
      })
    })

    describe("when the global PluginApi IS available", () => {
      const pluginFunction = jest.fn((plugin,state) => {
        return Promise.resolve(state);
      })
      beforeEach(() => {
        window.Plugins= {
          saveLearnerPluginState: pluginFunction
        }
      })
      it("should delegate saving to the plugin API", () => {
        expect.assertions(4);
        return LARA.saveLearnerPluginState(plugin, state)
          .then((d) =>  {
            expect(d).toMatch(state)
            expect(pluginFunction).toHaveBeenCalledTimes(1)
            expect(pluginFunction.mock.calls[0][0]).toBe(plugin)
            expect(pluginFunction.mock.calls[0][1]).toBe(state)
          })
      })
    })
  })

  describe("#registerPlugin", () => {
    const plugin = jest.fn()
    const label  = 'fakePlugin'
    let pluginFunction = jest.fn((plugin,state) => false)

    it("should exist", () => {
      expect(LARA.registerPlugin).toBeDefined();
    })

    describe("when the global PluginApiis NOT available", () => {
      it("should fail", () => {
        expect(LARA.registerPlugin(label, plugin)).toBe(false);
      })
    })

    describe("when the global PluginApi IS available", () => {
      beforeEach(() => {
        pluginFunction = jest.fn((plugin,state) => true);
        window.Plugins= {
          registerPlugin: pluginFunction
        }
      })
      describe("when the Plugin registration succeeds", () => {
        it("should delegate registration to the PluginsApi", () => {
          expect(LARA.registerPlugin(label, plugin)).toBe(true);
          expect(pluginFunction).toHaveBeenCalledTimes(1);
        })
      })
      describe("when the Plugin registration fails", () => {
        beforeEach(() => {
          pluginFunction = jest.fn((plugin,state) => false);
          window.Plugins= {
            registerPlugin: pluginFunction
          }
        })
        it("should delegate registration to the PluginsApi", () => {
          expect(LARA.registerPlugin(label, plugin)).toBe(false);
          expect(pluginFunction).toHaveBeenCalledTimes(1);
        })
      })
    })
  })
})
