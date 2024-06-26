import * as React from "react";
import { useState } from "react";
import { Modal, ModalButtons } from "../../../shared/components/modal/modal";
import { Add } from "../../../shared/components/icons/add-icon";
import { Close } from "../../../shared/components/icons/close-icon";
import { IPage } from "../../api/api-types";
import { RelativeLocation } from "../../util/move-utils";

import "./page-copy-dialog.scss";

export interface IPageCopyDialogProps {
  pageId: string;
  pages: IPage[];
  currentPageIndex: number | null;
  selectedPosition?: string;
  selectedOtherPagePosition?: number;
  copyPageFunction: (destIndex: number) => void;
  closeDialogFunction: () => void;
}

export const PageCopyDialog: React.FC<IPageCopyDialogProps> = ({
  pageId,
  pages,
  currentPageIndex,
  selectedPosition: initSelectedPosition = "after",
  selectedOtherPagePosition: initSelectedOtherPagePosition = 1,
  copyPageFunction,
  closeDialogFunction
  }: IPageCopyDialogProps) => {
  const [selectedOtherPagePosition, setSelectedOtherPagePosition] = useState(initSelectedOtherPagePosition);
  const [selectedPosition, setSelectedPosition] = useState(initSelectedPosition);

  const handlePositionChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedPosition(change.target.value);
  };

  const handleOtherPageChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedOtherPagePosition(parseInt(change.target.value, 10));
  };

  const handleCopyPage = () => {
    if (currentPageIndex != null && currentPageIndex > -1) {
      let destIndex = selectedOtherPagePosition;
      if (selectedPosition === RelativeLocation.After) {
        destIndex++;
      }
      copyPageFunction(destIndex);
    }
    closeDialogFunction();
  };

  const pageOptions = () => {
    const optionPages = pages.filter(p => !p.isCompletion);
    return optionPages.map((p, index) => {
      return <option key={`page-${index}`} value={p.position}>{p.position}{p.isHidden && ` (hidden)`}</option>;
    });
  };

  const modalButtons = [
    {classes: "cancel", clickHandler: closeDialogFunction, disabled: false, svg: <Close height="12" width="12"/>, text: "Cancel"},
    {classes: "copy", clickHandler: handleCopyPage, disabled: false, svg: <Add height="16" width="16"/>, text: "Copy"}
  ];

  return (
    <Modal title="Copy this page and move to..." visibility={true} closeFunction={closeDialogFunction}>
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
              <option value="">Select ...</option>
                {pageOptions()}
            </select>
          </dd>
        </dl>
        <ModalButtons buttons={modalButtons} />
      </div>
    </Modal>
  );
};
