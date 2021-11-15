import * as React from "react";
import { useEffect, useState } from "react";
import { createPortal } from "react-dom";
import { Close } from "../icons/close-icon";

import "./modal.scss";

export interface IModalButton {
  classes: string;
  clickHandler: (e: React.FormEvent | React.MouseEvent<HTMLElement> | MouseEvent) => void;
  disabled: boolean;
  svg: any;
  text: string;
}

export interface IModalButtonsProps {
  buttons: IModalButton[];
}

export interface IModalProps {
  children: JSX.Element;
  closeFunction?: (e: React.MouseEvent<HTMLElement> | MouseEvent) => void;
  title?: string;
  visibility: boolean;
  width?: number;
}

export const Modal: React.FC<IModalProps> = ({
  children,
  closeFunction,
  title,
  visibility: initVisibility = true,
  width
  }: IModalProps) => {

  const [isVisible, setIsVisible] = useState(initVisibility);
  const [modalContainer] = useState(() => {
    return document.createElement("div");
  });

  useEffect(() => {
    document.getElementById("modalContent")?.appendChild(modalContainer);
  }, []);

  const closeModal = () => {
    setIsVisible(false);
  };

  const closeButtonClickHandler = closeFunction ? closeFunction : closeModal;

  if (!isVisible) {
    return null;
  }

  return (
    <>
      <div className="modalOverlay" onClick={closeButtonClickHandler}/>
      <div id="modal" className="modalContainer">
        <div className="modalBody">
          <header>
            <h1>{title}</h1>
            <button aria-label="close" className="modalClose" onClick={closeButtonClickHandler}>
              <Close height="14" width="14" />
            </button>
          </header>
          <section id="modalContent">
            {createPortal(children, modalContainer)}
          </section>
        </div>
      </div>
    </>
  );
};

export const ModalButtons: React.FC<IModalButtonsProps> = ({
  buttons
  }: IModalButtonsProps) => {

  const renderButtons = () => {
    if (!buttons || buttons.length < 1) {
      return;
    }
    return buttons.map((b, index) => {
      return <button
               key={`${b.text}-button-${index}`}
               className={b.classes}
               disabled={b.disabled}
               onClick={b.clickHandler}
             >
               {b.svg} <span className="lineAdjust">{b.text}</span>
             </button>;
    });
  };

  return (
    <div className="actionButtons">
      {renderButtons()}
    </div>
  );
};
