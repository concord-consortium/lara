import React, { useState } from "react";
import { IPageProps } from "../../section-authoring/components/authoring-page";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { Add } from "../../shared/components/icons/add-icon";
import { Close } from "../../shared/components/icons/close-icon";

import "./page-copy-dialog.scss";

export interface IPageCopyDialogProps {
  pageId: string;
  pages: IPageProps[];
  currentPageIndex: number | null;
  selectedPosition?: string;
  selectedOtherPageId?: string;
  copyPageFunction: (pageId: string, selectedPosition: string, selectedOtherPageId: string) => void;
  closeDialogFunction: () => void;
}

export const PageCopyDialog: React.FC<IPageCopyDialogProps> = ({
  pageId,
  pages,
  currentPageIndex,
  selectedPosition: initSelectedPosition = "after",
  selectedOtherPageId: initSelectedOtherPageId = pageId,
  copyPageFunction,
  closeDialogFunction
  }: IPageCopyDialogProps) => {
  const [selectedOtherPageId, setSelectedOtherPageId] = useState(initSelectedOtherPageId);
  const [selectedPosition, setSelectedPosition] = useState(initSelectedPosition);

  const handlePositionChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedPosition(change.target.value);
  };

  const handleOtherPageChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedOtherPageId(change.target.value);
  };

  const handleCloseDialog = () => {
    closeDialogFunction();
  };

  const handleCopyPage = () => {
    if (currentPageIndex) {
      const copiedPageId = pages[currentPageIndex].id;
      copyPageFunction(copiedPageId, selectedPosition, selectedOtherPageId);
      closeDialogFunction();
    }
  };

  const pageOptions = () => {
    return pages.map((p, index) => {
      return <option key={`page-${index}`} value={p.id}>{index + 1}</option>;
    });
  };

  const modalButtons = [
    {classes: "cancel", clickHandler: handleCloseDialog, disabled: false, svg: <Close height="12" width="12"/>, text: "Cancel"},
    {classes: "copy", clickHandler: handleCopyPage, disabled: false, svg: <Add height="16" width="16"/>, text: "Copy"}
  ];

  return (
    <Modal title="Copy this page and move to..." visibility={true}>
      <div className="pageCopyDialog">
        <dl>
          <dt className="col1">Position</dt>
          <dd className="col1">
          <select name="position" onChange={handlePositionChange}>
              <option key="position-option-1" value="after">After</option>
              <option key="position-option-2" value="before">Before</option>
            </select>
          </dd>
          <dt className="col2">Page</dt>
          <dd className="col2">
            <select name="otherItem" onChange={handleOtherPageChange}>
              {pageOptions()}
            </select>
          </dd>
        </dl>
        <ModalButtons buttons={modalButtons} />
      </div>
    </Modal>
  );
};
