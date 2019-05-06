import * as Sidebar from "./sidebar";
import * as $ from "jquery";

describe("Sidebar", () => {
  it("should exist", () => {
    expect(Sidebar).toBeDefined();
  });

  describe("#addSidebar", () => {
    it("should exist", () => {
      expect(Sidebar.addSidebar).toBeDefined();
    });

    it("should handle basic options and create DOM element with correct content", () => {
      Sidebar.addSidebar({
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
    });

    it("returns a simple controller that can be used to open or close sidebar", () => {
      const onOpenCallback = jest.fn();
      const onCloseCallback = jest.fn();
      const controller = Sidebar.addSidebar({
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
    });

    describe("when user opens a sidebar", () => {
      it("it calls onOpen callback and main element gets expanded", () => {
        const onOpenCallback = jest.fn();
        Sidebar.addSidebar({
          content: $("<div id='test-sidebar'>Test sidebar</div>")[0],
          onOpen: onOpenCallback
        });
        $(".sidebar-hdr").click();
        expect(onOpenCallback).toHaveBeenCalledTimes(1);
        expect($(".sidebar-mod.expanded").length).toEqual(1);
      });
    });

    describe("when user closes a sidebar", () => {
      it("it calls onClose callback", () => {
        const onCloseCallback = jest.fn();
        Sidebar.addSidebar({
          content: $("<div id='test-sidebar'>Test sidebar</div>")[0],
          onClose: onCloseCallback
        });
        $(".sidebar-hdr").click(); // open
        $(".sidebar-hdr").click(); // close
        expect(onCloseCallback).toHaveBeenCalledTimes(1);
      });
    });
  });
});
