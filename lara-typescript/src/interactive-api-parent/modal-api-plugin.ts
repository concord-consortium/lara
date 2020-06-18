import { ICloseModal, IShowAlert, IShowDialog, IShowLightbox, IShowModal, ModalType
        } from "../interactive-api-client";
import { IFrameSaverPlugin } from "./iframe-saver-plugin";
import { addPopup } from "../plugin-api";

interface ModalState {
  type: ModalType;
  $content: JQuery<HTMLElement>;
}
const modalMap: Record<string, ModalState> = {};

export function ModalApiPlugin(): IFrameSaverPlugin {
  return {
    listeners: {
      showModal: (options: IShowModal) => {
        const fnMap: Record<ModalType, (opts: IShowModal) => void> = {
          alert: (opts: IShowAlert) => showAlert(opts),
          lightbox: (opts: IShowLightbox) => showLightbox(opts),
          dialog: (opts: IShowDialog) => showDialog(opts)
        };
        const showFn = fnMap[options.type];
        showFn?.(options);
      },
      closeModal: (options: ICloseModal) => {
        const fnMap: Record<ModalType, (opts: ICloseModal) => void> = {
          alert: (opts: ICloseModal) => closeAlert(opts),
          lightbox: (opts: ICloseModal) => closeLightbox(opts),
          dialog: (opts: ICloseModal) => closeDialog(opts)
        };
        const type = modalMap[options.uuid]?.type;
        const closeFn = type && fnMap[type];
        closeFn?.(options);
      }
    }
  };
}

function showAlert(options: IShowAlert) {
  const { style, title: _title, text } = options;
  let title: string;
  let titlebarColor: string | undefined;
  let message: string;
  if (style === "correct") {
    title = _title != null ? _title : "Correct";
    titlebarColor = "#75a643";
    message = text || "Yes! You are correct.";
  }
  else if (style === "incorrect") {
    title = _title != null ? _title : "Incorrect";
    titlebarColor = "#b45532";
    message = text || "Sorry, that is incorrect.";
  }
  else {
    title = _title || "";
    message = text || "";
  }

  const $content = $(`<div class='check-answer'><p class='response'>${message}</p></div`);
  modalMap[options.uuid] = { type: options.type, $content };
  addPopup({
    content: $content[0],
    title,
    titlebarColor,
    modal: true,
    onClose: () => delete modalMap[options.uuid]
  });
}

function closeAlert(options: ICloseModal) {
  const $content = modalMap[options.uuid]?.$content;
  if ($content?.is(":ui-dialog")) {
    $content.dialog("close");
  }
}

function showLightbox(options: IShowLightbox) {
  const getSizeOptions = () => {
    const { isImage, size } = options;
    // colorbox implementation detail
    const kChromeSize = { width: 42, height: 70 };
    const availableWidth = window.innerWidth - kChromeSize.width;
    const availableHeight = window.innerHeight - kChromeSize.height;
    const sizeOpts: { width?: number, height?: number, scalePhotos?: boolean } = {};
    // images are auto-sized correctly without intervention
    if (isImage) {
      // prevent scaling up unless requested
      const requiresUpscaling = (!!size?.width && size.width < availableWidth) &&
                                (!!size?.height && size.height < availableHeight);
      sizeOpts.scalePhotos = !requiresUpscaling || options.allowUpscale;
      return sizeOpts;
    }
    // for iframes, if size is specified, then maintain aspect ratio
    if (size) {
      const aspectRatio = size.width / size.height;
      if (size.height > availableHeight) {
        // height is constraining dimension
        sizeOpts.width = availableHeight * aspectRatio;
        sizeOpts.height = availableHeight;
      }
      else {
        sizeOpts.width = size.width;
        sizeOpts.height = size.height;
      }
      if (size.width > availableWidth) {
        // width is constraining dimension
        sizeOpts.width = availableWidth;
        sizeOpts.height = availableWidth / aspectRatio;
      }
      return sizeOpts;
    }
    // otherwise use available space
    sizeOpts.width = availableWidth;
    sizeOpts.height = availableHeight;
    return sizeOpts;
  };
  ($ as any).colorbox({
    iframe: !options.isImage,
    photo: !!options.isImage,
    href: options.url,
    title: options.title,
    maxWidth: "100%",
    maxHeight: "100%",
    ...getSizeOptions(),
    onOpen: () => modalMap[options.uuid] = { type: "lightbox", $content: ($ as any).colorbox.element() },
    onClosed: () => delete modalMap[options.uuid]
  });
}

function closeLightbox(options: ICloseModal) {
  ($ as any).colorbox.close();
}

function showDialog(options: IShowDialog) {
  // dialog
}

function closeDialog(options: ICloseModal) {
  // dialog
}
