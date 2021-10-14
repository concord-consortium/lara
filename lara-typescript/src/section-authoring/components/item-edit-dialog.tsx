import * as React from "react";
import { useState } from "react";
import { ISectionItem, ITextBlockData } from "../api/api-types";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { TextBlockEditForm } from "./text-block-edit-form";
import { Save } from "../../shared/components/icons/save-icon";
import { Close } from "../../shared/components/icons/close-icon";
import { usePageAPI } from "../api/use-api-provider";
import { UserInterfaceContext } from "../api/use-user-interface-context";

import "./item-edit-dialog.scss";

export interface IItemEditDialogProps {
  errorMessage?: string;
}

export const ItemEditDialog: React.FC<IItemEditDialogProps> = ({
  errorMessage
  }: IItemEditDialogProps) => {
  const { userInterface: {editingItemId}, actions: {setEditingItemId}} = React.useContext(UserInterfaceContext);
  const api = usePageAPI();
  const updatePageItem = api.updatePageItem;
  const pageItems = api.getItems();
  const pageItem = pageItems.find(pi => pi.id === editingItemId);
  const [modalVisibility, setModalVisibility] = useState(true);
  const [itemData, setItemData] = useState({});

  const handleUpdateData = (updateItemData: ITextBlockData) => {
    setItemData(updateItemData);
  };

  const handleUpdateItem = () => {
    if (pageItem && itemData !== {}) {
      pageItem.data = itemData;
      updatePageItem(pageItem);
    }
    handleCloseDialog();
  };

  const handleCancelUpdateItem = () => {
    handleCloseDialog();
  };

  const handleCloseDialog = () => {
    setEditingItemId(false);
  };

  const modalButtons = [
    {
      classes: "cancel",
      clickHandler: handleCancelUpdateItem,
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

  if (pageItem) {
    return (
      <Modal title="Edit" closeFunction={handleCancelUpdateItem} visibility={modalVisibility} width={600}>
        <div className="itemEditDialog">
          {errorMessage &&
            <div className="errorMessage">
              {errorMessage}
            </div>
          }
          <TextBlockEditForm pageItem={pageItem} handleUpdateData={handleUpdateData} />
          <ModalButtons buttons={modalButtons} />
        </div>
      </Modal>
    );
  }
  return null;
};
