import * as React from "react";
import { useEffect, useState } from "react";
import { ISectionItem, ITextBlockData } from "../api/api-types";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { TextBlockEditForm } from "./text-block-edit-form";
import { IManagedInteractive, ManagedInteractiveAuthoring } from "../../page-item-authoring/managed-interactives";
import { Save } from "../../shared/components/icons/save-icon";
import { Close } from "../../shared/components/icons/close-icon";
import { usePageAPI } from "../hooks/use-api-provider";
import { UserInterfaceContext } from "../containers/user-interface-provider";
import { BucketLifecycleConfiguration } from "@aws-sdk/client-s3";
import { camelToSnakeCaseKeys } from "../../shared/convert-keys";

import "./item-edit-dialog.scss";

export interface IItemEditDialogProps {
  errorMessage?: string;
}

export const ItemEditDialog: React.FC<IItemEditDialogProps> = ({
  errorMessage
  }: IItemEditDialogProps) => {
  const { userInterface: {editingItemId}, actions: {setEditingItemId}} = React.useContext(UserInterfaceContext);
  const { getItems, updatePageItem, getLibraryInteractives } = usePageAPI();
  const pageItems = getItems();
  const pageItem = pageItems.find(pi => pi.id === editingItemId);
  const [modalVisibility, setModalVisibility] = useState(true);
  const [itemData, setItemData] = useState({});
  const libraryInteractives = getLibraryInteractives.data?.libraryInteractives;

  const handleUpdateTextBlockData = (updateItemData: ITextBlockData) => {
    setItemData(updateItemData);
  };

  const handleManagedInteractiveData = (updates: Partial<IManagedInteractive>) => {
    const newData = {...itemData, ...updates};
    setItemData(newData);
  };

  const handleUpdateItem = () => {
    if (pageItem && itemData !== {}) {
      pageItem.data = {...pageItem.data, ...itemData};
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

  // for now, this is just a placeholder in case it's needed in the future
  const constructAuthoringApiUrls = () => {
    return {

    };
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

  const getEditForm = (itemToEdit: ISectionItem) => {
    switch (itemToEdit.type) {
      case "Embeddable::Xhtml":
        return <TextBlockEditForm pageItem={itemToEdit} handleUpdateData={handleUpdateTextBlockData} />;
        break;
      case "ManagedInteractive":
        const managedInteractive = camelToSnakeCaseKeys(itemToEdit.data);
        const libraryInteractive = camelToSnakeCaseKeys(
                                     libraryInteractives?.find(
                                       li => li.id === itemToEdit.data.libraryInteractiveId
                                     )
                                   );
        const authoringApiUrls = constructAuthoringApiUrls();
        return <ManagedInteractiveAuthoring
                managedInteractive={managedInteractive}
                libraryInteractive={libraryInteractive}
                defaultClickToPlayPrompt={"Click to Play"}
                authoringApiUrls={authoringApiUrls}
                onUpdate={handleManagedInteractiveData}
               />;
        break;
      default:
        return "Editing not supported.";
    }
  };

  if (pageItem) {
    return (
      <Modal title="Edit" closeFunction={handleCancelUpdateItem} visibility={modalVisibility}>
        <div className="itemEditDialog">
          {errorMessage &&
            <div className="errorMessage">
              {errorMessage}
            </div>
          }
          {getEditForm(pageItem)}
          <ModalButtons buttons={modalButtons} />
        </div>
      </Modal>
    );
  }
  return null;
};
