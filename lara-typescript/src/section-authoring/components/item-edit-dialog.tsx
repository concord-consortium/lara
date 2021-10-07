import * as React from "react";
import { useState } from "react";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { TextBlockEditForm } from "./text-block-edit-form";
import { Save } from "../../shared/components/icons/save-icon";
import { Close } from "../../shared/components/icons/close-icon";

import "./item-edit-dialog.scss";

export interface IItemEditDialogProps {
  closeDialogFunction: () => void;
  errorMessage?: string;
  item: any;
  updateFunction: (itemId: string) => void;
}

export const ItemEditDialog: React.FC<IItemEditDialogProps> = ({
  closeDialogFunction,
  errorMessage,
  item,
  updateFunction
  }: IItemEditDialogProps) => {
  const [modalVisibility, setModalVisibility] = useState(true);

  const handleChangeContent = () => {
    return;
  };

  const handleChangeIsCallout = () => {
    return;
  };

  const handleChangeIsFullWidth = () => {
    return;
  };

  const handleUpdateItem = () => {
    handleCloseDialog();
  };

  const handleCloseDialog = () => {
    closeDialogFunction();
  };

  const modalButtons = [
    {
      classes: "cancel",
      clickHandler: handleCloseDialog,
      disabled: false,
      svg: <Close height="12" width="12"/>,
      text: "Cancel"
    },
    {
      classes: "save",
      clickHandler: handleUpdateItem,
      disabled: false,
      svg: <Save height="16" width="16"/>,
      text: "Save"
    }
  ];

  return (
    <Modal title="Edit" closeFunction={handleCloseDialog} visibility={modalVisibility} width={600}>
      <div className="itemEditDialog">
        {errorMessage &&
          <div className="errorMessage">
            {errorMessage}
          </div>
        }
        <TextBlockEditForm pageItem={item} />
        <ModalButtons buttons={modalButtons} />
      </div>
    </Modal>
  );
};
