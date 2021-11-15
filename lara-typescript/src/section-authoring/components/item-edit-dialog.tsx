import * as React from "react";
import { useEffect, useState } from "react";
import { ISectionItem, ITextBlockData } from "../api/api-types";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { TextBlockEditForm } from "./text-block-edit-form";
import { IManagedInteractive, ManagedInteractiveAuthoring } from "../../page-item-authoring/managed-interactives";
import { IMWInteractive, MWInteractiveAuthoring} from "../../page-item-authoring/mw-interactives";
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

  useEffect(() => {
    handleUpdateItem();
  }, [itemData]);

  const handleUpdateTextBlockData = (updates: ITextBlockData) => {
    setItemData(updates);
  };

  const handleManagedInteractiveData = (updates: Partial<IManagedInteractive>) => {
    const newData = {...itemData, ...updates};
    setItemData(newData);
  };

  const handleMwInteractiveData = (updates: Partial<IMWInteractive>) => {
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

  const handleBooleanElement = (element: HTMLInputElement) => {
    // boolean value form fields are of type radio or of type hidden
    const elementValue = element.type === "radio" ?
      (document.querySelector(`input[name="${element.name}"]:checked`) as HTMLInputElement).value
      : element.value;
    return elementValue === "true" || elementValue === "1";
  };

  const handleSave = () => {
    const form = document.getElementById("itemEditForm");
    form?.dispatchEvent(new Event("submit"));
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formElements = e.currentTarget.elements;
    const updates: any = {};
    Array.prototype.forEach.call(formElements, (element: HTMLInputElement | HTMLTextAreaElement) => {
      if (element.name && element.name !== "") {
        // some values need to be converted from strings to booleans or numbers
        let elementValue: string | number | boolean = "";
        switch (element.name) {
          case "inherit_aspect_ratio_method":
          case "inherit_click_to_play":
          case "inherit_click_to_play_prompt":
          case "inherit_full_window":
          case "inherit_image_url":
          case "inherit_native_height":
          case "inherit_native_width":
            elementValue = handleBooleanElement((element as HTMLInputElement));
            break;
          case "library_interactive_id":
            elementValue = parseInt(element.value, 10);
            break;
          default:
            elementValue = element.type === "checkbox" ? (element as HTMLInputElement).checked : element.value;
        }
        updates[element.name] = elementValue;
      }
    });
    switch (pageItem?.type) {
      case "Embeddable::Xhtml":
        handleUpdateTextBlockData(updates);
        break;
      case "ManagedInteractive":
        handleManagedInteractiveData(updates);
        break;
      case "MwInteractive":
        handleMwInteractiveData(updates);
        break;
    }
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
      clickHandler: handleSave,
      disabled: false,
      svg: <Save height="16" width="16"/>,
      text: "Save"
    }
  ];

  const getEditForm = (itemToEdit: ISectionItem) => {
    const authoringApiUrls = constructAuthoringApiUrls();
    switch (itemToEdit.type) {
      case "Embeddable::Xhtml":
        return <TextBlockEditForm pageItem={itemToEdit} />;
        break;
      case "ManagedInteractive":
        const managedInteractive = camelToSnakeCaseKeys(itemToEdit.data);
        const libraryInteractive = camelToSnakeCaseKeys(
                                     libraryInteractives?.find(
                                       li => li.id === itemToEdit.data.libraryInteractiveId
                                     )
                                   );
        return <ManagedInteractiveAuthoring
                managedInteractive={managedInteractive}
                libraryInteractive={libraryInteractive}
                defaultClickToPlayPrompt={"Click to Play"}
                authoringApiUrls={authoringApiUrls}
                onUpdate={handleManagedInteractiveData}
               />;
        break;
      case "MwInteractive":
        const interactive = camelToSnakeCaseKeys(itemToEdit.data);
        return <MWInteractiveAuthoring
                interactive={interactive}
                defaultClickToPlayPrompt={"Click to Play"}
                authoringApiUrls={authoringApiUrls}
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
          <form id="itemEditForm" onSubmit={handleSubmit}>
            {getEditForm(pageItem)}
            <ModalButtons buttons={modalButtons} />
          </form>
        </div>
      </Modal>
    );
  }
  return null;
};
