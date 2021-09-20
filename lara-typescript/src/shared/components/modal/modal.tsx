import React, { useEffect, useState } from "react";
import { createPortal } from "react-dom";
import { Close } from "../icons/close-icon";

import "./modal.scss";

export interface IModalProps {
  children: JSX.Element;
  title?: string;
  visibility: boolean;
  width?: number;
}

export const Modal: React.FC<IModalProps> = ({
  children,
  title,
  visibility: initVisibility = true,
  width
  }: IModalProps) => {

  const modalStyle = width ? { width: width + "px" } : undefined;
  const [isVisible, setIsVisible] = useState(initVisibility);
  const [modalContainer] = useState(() => {
    return document.createElement('div');
  });

  useEffect(() => {
    document.getElementById("modal-content")?.appendChild(modalContainer);
  }, []);

  const closeModal = () => {
    setIsVisible(false);
  }

  if (!isVisible) {
    return null;
  }

  return (
    <>
      <div className="modalOverlay"></div>
      <div id="modal" className="modal" style={modalStyle}>
        <header>
          <h1>{title}</h1>
          <button aria-label="close" className="modalClose" onClick={closeModal}>
            <Close height="14" width="14" />
          </button>
        </header>
        <section id="modal-content">
          {createPortal(children, modalContainer)}
        </section>
      </div>
    </>
  );
};
