import * as Popup from "./popup";

describe("Popup", () => {
  it("should exist", () => {
    expect(Popup).toBeDefined();
  });

  describe("#addPopup", () => {
    it("should exist", () => {
      expect(Popup.addPopup).toBeDefined();
    });

    it("should handle basic options and create DOM element with correct content", () => {
      const content = $("<div id='test-dialog'>Test dialog</div>")[0];
      Popup.addPopup({
        content,
        title: "Test title"
      });
      expect($("body").find("#test-dialog").length).toEqual(1);
      expect($("body").text()).toEqual(expect.stringContaining("Test dialog"));
      expect($("body").text()).toEqual(expect.stringContaining("Test title"));
    });

    describe("when user closes a dialog", () => {
      it("it removes container from the DOM if removeOnClose is equal to true and calls onRemove", () => {
        const content = $("<div id='test-dialog'>Test dialog</div>")[0];
        const onRemoveCallback = jest.fn();
        Popup.addPopup({ content, removeOnClose: true, onRemove: onRemoveCallback });
        expect($("body").find("#test-dialog").length).toEqual(1);
        $(".ui-dialog-titlebar-close").click();
        expect($("body").find("#test-dialog").length).toEqual(0);
        expect(onRemoveCallback).toHaveBeenCalledTimes(1);
      });

      it("it doesn't remove container from the DOM if removeOnClose is equal to false", () => {
        const content = $("<div id='test-dialog'>Test dialog</div>")[0];
        const onRemoveCallback = jest.fn();
        Popup.addPopup({ content, removeOnClose: false, onRemove: onRemoveCallback });
        expect($("body").find("#test-dialog").length).toEqual(1);
        $(".ui-dialog-titlebar-close").click();
        expect($("body").find("#test-dialog").length).toEqual(1);
        expect(onRemoveCallback).toHaveBeenCalledTimes(0);
      });

      it("it calls onClose callback", () => {
        const content = $("<div id='test-dialog'>Test dialog</div>")[0];
        const onCloseCallback = jest.fn();
        Popup.addPopup({
          content,
          onClose: onCloseCallback
        });
        $(".ui-dialog-titlebar-close").click();
        expect(onCloseCallback).toHaveBeenCalledTimes(1);
      });
    });
  });
});
