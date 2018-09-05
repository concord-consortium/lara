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
})

