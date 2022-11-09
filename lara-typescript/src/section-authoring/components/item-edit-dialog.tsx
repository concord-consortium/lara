import * as React from "react";
import { useEffect, useRef, useState } from "react";
import { ISectionItem, ITextBlockData } from "../api/api-types";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { TextBlockEditForm } from "./text-block-edit-form";
import { IManagedInteractive, ManagedInteractiveAuthoring } from "../../page-item-authoring/managed-interactives";
import { IMWInteractive, MWInteractiveAuthoring } from "../../page-item-authoring/mw-interactives";
import { PluginAuthoring } from "./plugin-authoring";
import { Save } from "../../shared/components/icons/save-icon";
import { Close } from "../../shared/components/icons/close-icon";
import { usePageAPI } from "../hooks/use-api-provider";
import { UserInterfaceContext } from "../containers/user-interface-provider";
import { camelToSnakeCaseKeys } from "../../shared/convert-keys";
import { TextBlockPreview } from "./text-block-preview";
import { ManagedInteractivePreview } from "./managed-interactive-preview";
import { MWInteractivePreview } from "./mw-interactive-preview";
import classNames from "classnames";

import "./item-edit-dialog.scss";

export interface IItemEditDialogProps {
  errorMessage?: string;
}

export const ItemEditDialog: React.FC<IItemEditDialogProps> = ({
  errorMessage
  }: IItemEditDialogProps) => {
  const {
    userInterface: {editingItemId, wrappedItemId},
    actions: {setEditingItemId, setWrappedItemId}
  } = React.useContext(UserInterfaceContext);
  const { getItems, updatePageItem, getLibraryInteractives } = usePageAPI();
  const pageItems = getItems();
  const pageItem = pageItems.find(pi => pi.id === editingItemId);
  const wrappedItem = pageItems.find(pi => pi.id === wrappedItemId);
  const [previewPageItem, setPreviewPageItem] = useState<ISectionItem>();
  const [modalVisibility, setModalVisibility] = useState(true);
  const [itemData, setItemData] = useState({});
  const libraryInteractives = getLibraryInteractives.data?.libraryInteractives;

  useEffect(() => {
    if (Object.keys(itemData).length > 0) {
      handleUpdateItem();
    }
  }, [itemData]);

  useEffect(() => {
    setItemData({});
  }, [editingItemId]);

  useEffect(() => {
    if (!previewPageItem) {
      setPreviewPageItem(pageItem);
    }
  }, [pageItem]);

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

  const handlePluginData = (authorData: string) => {
    setItemData({authorData});
  };

  const handleUpdateItem = () => {
    if (pageItem) {
      const pageItemUpdateOpts = {...pageItem};
      pageItemUpdateOpts.data = {...pageItem.data, ...itemData};
      updatePageItem(pageItemUpdateOpts);
    }
    handleCloseDialog();
  };

  const handleUpdateItemPreview = (updates: Record<string, any> | Partial<IManagedInteractive>) => {
    if (previewPageItem) {
      const data = {...previewPageItem.data, ...updates};
      setPreviewPageItem({...previewPageItem, data});
    } else if (pageItem) {
      const data = {...pageItem.data, ...updates};
      setPreviewPageItem({...pageItem, data});
    }
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
    setWrappedItemId(false);
    setItemData({});
    setPreviewPageItem(undefined);
  };

  const interactiveFromItemToEdit = (itemToEdit: ISectionItem) => {
    const interactive = camelToSnakeCaseKeys(itemToEdit.data);
    interactive.interactive_item_id = `interactive_${itemToEdit.id}`;
    return interactive;
  };

  const standardModalButtons = [
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

  let modalButtons = standardModalButtons;
  if (pageItem && pageItem.type === "Embeddable::EmbeddablePlugin") {
    // The authoring form of plugins supply their own buttons,
    // So we remove the standard buttons from the modal.
    const pluginModalButtons: any[] = [];
    modalButtons = pluginModalButtons;
  }
  const getEditForm = (itemToEdit: ISectionItem) => {
    const authoringApiUrls = itemToEdit.authoring_api_urls ? itemToEdit.authoring_api_urls : {};
    switch (itemToEdit.type) {
      case "Embeddable::Xhtml":
        return <TextBlockEditForm
                 pageItem={itemToEdit}
                 handleUpdateItemPreview={handleUpdateItemPreview}
               />;
      case "ManagedInteractive":
        const managedInteractive = interactiveFromItemToEdit(itemToEdit);
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
                handleUpdateItemPreview={handleUpdateItemPreview}
               />;
      case "MwInteractive":
        const interactive = interactiveFromItemToEdit(itemToEdit);
        return <MWInteractiveAuthoring
                interactive={interactive}
                defaultClickToPlayPrompt={"Click to Play"}
                authoringApiUrls={authoringApiUrls}
                handleUpdateItemPreview={handleUpdateItemPreview}
               />;
      case "Embeddable::EmbeddablePlugin":
        return <PluginAuthoring
          pageItem={itemToEdit}
          authoringApiUrls={authoringApiUrls}
          onUpdate={handlePluginData}
          closeForm={handleCancelUpdateItem}
          wrappedItem={wrappedItem}
          />;
      default:
        return "Editing not supported.";
    }
  };

  const supportsPreview = () => {
    return pageItem && pageItem.type === "Embeddable::Xhtml" ||
           pageItem && pageItem.type === "ManagedInteractive" ||
           pageItem && pageItem.type === "MwInteractive";
  };

  const getPreview = () => {
    const previewNote = <p className="previewNote">
      This preview does not yet reflect all features and settings available in the edit form.
      To view exactly how this assessment item will appear in runtime, please save your changes
      and preview the activity in Activity Player.
    </p>;
    if (pageItem && previewPageItem) {
      switch (pageItem.type) {
        case "Embeddable::Xhtml":
          return <TextBlockPreview pageItem={previewPageItem} />;
        case "ManagedInteractive":
          return <>
            <ManagedInteractivePreview
              pageItem={previewPageItem}
            />
            {previewNote}
          </>;
        case "MwInteractive":
          return <>
            <MWInteractivePreview
              pageItem={previewPageItem}
            />
            {previewNote}
          </>;
        default:
          return `Preview not supported for item type ${pageItem.type}.`;
      }
    }
  };

  if (pageItem) {
    const formClassName = classNames({noPreview: !supportsPreview()});
    return (
      <Modal
        title="Edit"
        className="itemEditDialog"
        closeFunction={handleCancelUpdateItem}
        visibility={modalVisibility}
      >
        <div id="itemEditDialog">
          {errorMessage &&
            <div className="errorMessage">
              {errorMessage}
            </div>
          }
          <form id="itemEditForm" onSubmit={handleSubmit} className={formClassName}>
            {getEditForm(pageItem)}
            <ModalButtons buttons={modalButtons} />
          </form>
            {supportsPreview() &&
              <div className="itemEditPreview">
                <h2>Preview</h2>
                  <div className="itemEditPreviewContent">
                  {getPreview()}
                </div>
              </div>
            }
        </div>
      </Modal>
    );
  }
  return null;
};
