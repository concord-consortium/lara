import { hasModal, ModalApiPlugin } from "./modal-api-plugin";
import { IShowModal, ICloseModal } from "../interactive-api-client";
import { MockPhone } from "./mock-iframe-phone";
import "../../../app/assets/javascripts/jquery.colorbox";

const parentEl = document.createElement("iframe");
const mockPhone = new MockPhone(parentEl);
const disconnect = ModalApiPlugin(mockPhone);

afterAll(() => {
  disconnect();
  expect(mockPhone.hasListener("showModal")).toBe(false);
  expect(mockPhone.hasListener("closeModal")).toBe(false);
});

describe("ModalApiPlugin should show/close alerts", () => {

  it("should show/hide correct alert", () => {
    const uuid = "correct-alert";
    expect(hasModal(uuid)).toBe(false);
    expect($(".ui-dialog").length).toBe(0);
    const showOptions: IShowModal = { uuid, type: "alert", style: "correct" };
    mockPhone.fakeServerMessage({ type: "showModal", content: showOptions });
    expect(hasModal(uuid)).toBe(true);
    expect($(".ui-dialog").length).toBe(1);
    expect($(".ui-dialog").find(".ui-dialog-titlebar").text()).toMatch(/^Correct/);
    const closeOptions: ICloseModal = { uuid };
    mockPhone.fakeServerMessage({ type: "closeModal", content: closeOptions });
    expect(hasModal(uuid)).toBe(false);
    expect($(".ui-dialog").length).toBe(0);
  });

  it("should show/hide incorrect alert", () => {
    const uuid = "incorrect-alert";
    expect(hasModal(uuid)).toBe(false);
    expect($(".ui-dialog").length).toBe(0);
    const showOptions: IShowModal = { uuid, type: "alert", style: "incorrect" };
    mockPhone.fakeServerMessage({ type: "showModal", content: showOptions });
    expect(hasModal(uuid)).toBe(true);
    expect($(".ui-dialog").length).toBe(1);
    expect($(".ui-dialog").find(".ui-dialog-titlebar").text()).toMatch(/^Incorrect/);
    const closeOptions: ICloseModal = { uuid };
    mockPhone.fakeServerMessage({ type: "closeModal", content: closeOptions });
    expect(hasModal(uuid)).toBe(false);
    expect($(".ui-dialog").length).toBe(0);
  });

  it("should show/hide info alert", () => {
    const uuid = "info-alert";
    expect(hasModal(uuid)).toBe(false);
    expect($(".ui-dialog").length).toBe(0);
    const showOptions: IShowModal = { uuid, type: "alert", style: "info", text: "Information" };
    mockPhone.fakeServerMessage({ type: "showModal", content: showOptions });
    expect(hasModal(uuid)).toBe(true);
    expect($(".ui-dialog").length).toBe(1);
    expect($(".ui-dialog").find(".ui-dialog-content").text()).toMatch(/^Information/);
    const closeOptions: ICloseModal = { uuid };
    mockPhone.fakeServerMessage({ type: "closeModal", content: closeOptions });
    expect(hasModal(uuid)).toBe(false);
    expect($(".ui-dialog").length).toBe(0);
  });
});

describe("ModalApiPlugin should show/close lightboxes", () => {
  const $colorbox = ($ as any).colorbox;

  beforeEach(() => {
    $colorbox.remove();
  });

  // cf. https://swizec.com/blog/how-to-properly-wait-for-dom-elements-to-show-up-in-modern-browsers/swizec/6663
  function waitForElement(selector: string, callback: () => void) {
    function wait() {
      if (!$(selector).length) {
        window.requestAnimationFrame(wait);
      }
      else {
        callback();
      }
    }
    wait();
  }

  function waitForNoElement(selector: string, callback: () => void) {
    function wait() {
      if ($(selector).length && ($(selector).css("display") !== "none")) {
        window.requestAnimationFrame(wait);
      }
      else {
        setTimeout(() => callback(), 10);
      }
    }
    wait();
  }

  it("should show/hide modal image lightbox", done => {
    const uuid = "image-lightbox";
    expect($("#colorbox").length).toBe(0);
    expect(hasModal(uuid)).toBe(false);
    const showOptions: IShowModal = { uuid, type: "lightbox", isImage: true, url: "https://concord.org" };
    mockPhone.fakeServerMessage({ type: "showModal", content: showOptions });
    waitForElement("#colorbox", () => {
      expect(hasModal(uuid)).toBe(true);

      const closeOptions: ICloseModal = { uuid };
      mockPhone.fakeServerMessage({ type: "closeModal", content: closeOptions });
      waitForNoElement("#colorbox", () => {
        expect(hasModal(uuid)).toBe(false);
        done();
      });
    });
  });

  it("should show/hide modal iframe lightbox", done => {
    const uuid = "iframe-lightbox";
    expect($("#colorbox").length).toBe(0);
    expect(hasModal(uuid)).toBe(false);
    const showOptions: IShowModal = { uuid, type: "lightbox", url: "https://concord.org" };
    mockPhone.fakeServerMessage({ type: "showModal", content: showOptions });
    waitForElement("#colorbox iframe", () => {
      expect(hasModal(uuid)).toBe(true);

      const closeOptions: ICloseModal = { uuid };
      mockPhone.fakeServerMessage({ type: "closeModal", content: closeOptions });
      waitForNoElement("#colorbox", () => {
        expect(hasModal(uuid)).toBe(false);
        expect($("#colorbox iframe").length).toBe(0);
        done();
      });
    });
  });

  it("should show/hide modal iframe lightbox with size", done => {
    const uuid = "iframe-lightbox-size";
    expect($("#colorbox").length).toBe(0);
    expect(hasModal(uuid)).toBe(false);
    const showOptions: IShowModal = { uuid, type: "lightbox", url: "https://concord.org",
                                      size: { width: 800, height: 600 } };
    mockPhone.fakeServerMessage({ type: "showModal", content: showOptions });
    waitForElement("#colorbox iframe", () => {
      expect(hasModal(uuid)).toBe(true);

      const closeOptions: ICloseModal = { uuid };
      mockPhone.fakeServerMessage({ type: "closeModal", content: closeOptions });
      waitForNoElement("#colorbox", () => {
        expect(hasModal(uuid)).toBe(false);
        expect($("#colorbox iframe").length).toBe(0);
        done();
      });
    });
  });

  it("should show/hide wide modal iframe lightbox with size", done => {
    const uuid = "iframe-lightbox-wide";
    expect($("#colorbox").length).toBe(0);
    expect(hasModal(uuid)).toBe(false);
    const showOptions: IShowModal = { uuid, type: "lightbox", url: "https://concord.org",
                                      size: { width: 8000, height: 600 } };
    mockPhone.fakeServerMessage({ type: "showModal", content: showOptions });
    waitForElement("#colorbox iframe", () => {
      expect(hasModal(uuid)).toBe(true);

      const closeOptions: ICloseModal = { uuid };
      mockPhone.fakeServerMessage({ type: "closeModal", content: closeOptions });
      waitForNoElement("#colorbox", () => {
        expect(hasModal(uuid)).toBe(false);
        expect($("#colorbox iframe").length).toBe(0);
        done();
      });
    });
  });

  it("should show/hide tall modal iframe lightbox with size", done => {
    const uuid = "iframe-lightbox-tall";
    expect($("#colorbox").length).toBe(0);
    expect(hasModal(uuid)).toBe(false);
    const showOptions: IShowModal = { uuid, type: "lightbox", url: "https://concord.org",
                                      size: { width: 800, height: 6000 } };
    mockPhone.fakeServerMessage({ type: "showModal", content: showOptions });
    waitForElement("#colorbox iframe", () => {
      expect(hasModal(uuid)).toBe(true);

      const closeOptions: ICloseModal = { uuid };
      mockPhone.fakeServerMessage({ type: "closeModal", content: closeOptions });
      waitForNoElement("#colorbox", () => {
        expect(hasModal(uuid)).toBe(false);
        expect($("#colorbox iframe").length).toBe(0);
        done();
      });
    });
  });
});

describe("ModalApiPlugin should show/close dialogs", () => {

  it("should implement showDialog/closeDialog functions", () => {
    const uuid = "dialog";
    expect(hasModal(uuid)).toBe(false);
    const showOptions: IShowModal = { uuid, type: "dialog", url: "https://concord.org" };
    mockPhone.fakeServerMessage({ type: "showModal", content: showOptions });
    expect(hasModal(uuid)).toBe(true);
    const closeOptions: ICloseModal = { uuid };
    mockPhone.fakeServerMessage({ type: "closeModal", content: closeOptions });
    expect(hasModal(uuid)).toBe(false);
  });
});
