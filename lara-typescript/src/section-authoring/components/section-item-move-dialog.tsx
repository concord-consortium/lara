import * as React from "react";
import { useState } from "react";
import { ISectionItem, ISection, SectionColumns, PageId } from "../api/api-types";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { Close } from "../../shared/components/icons/close-icon";
import { Move } from "../../shared/components/icons/move-icon";
import { usePageAPI } from "../hooks/use-api-provider";
import { UserInterfaceContext } from "../containers/user-interface-provider";

import "./section-item-move-dialog.scss";
import { RelativeLocation } from "../util/move-utils";
import { useDestinationChooser } from "../hooks/use-destination-chooser";

export const SectionItemMoveDialog: React.FC = () => {
  const { moveItem, getSections  } = usePageAPI();
  const { userInterface: {movingItemId}, actions: {setMovingItemId}} = React.useContext(UserInterfaceContext);
  const [selectedColumn, setSelectedColumn] = useState(SectionColumns.PRIMARY);
  const [selectedOtherItemId, setSelectedOtherItemId] = useState("");
  const {
    sections, selectedSectionId,
    pagesForPicking, handlePageChange, selectedPageId, validPage,
    handlePositionChange, selectedPosition,
    handleSectionChange, validSection
  } = useDestinationChooser();

  const handleColumnChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedColumn(change.target.value as SectionColumns);
  };

  const handleOtherItemChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedOtherItemId(change.target.value);
  };

  const handleCloseDialog = () => {
    setMovingItemId(false);
  };

  const handleMoveItem = () => {
    if (movingItemId) {
      moveItem(movingItemId, {
        destPageId: selectedPageId,
        destSectionId: selectedSectionId,
        destItemId: selectedOtherItemId,
        relativeLocation: selectedPosition,
        destColumn: selectedColumn as SectionColumns
      });
    }
    handleCloseDialog();
  };

  const columnOptions = () => {
    const options: any = [{value: SectionColumns.PRIMARY}];
    if (selectedSectionId) {
      const section = getSections().find(s => s.id === selectedSectionId);
      if (section?.layout !== "Full Width") {
        options.push({value: SectionColumns.SECONDARY});
      }
    }
    return options.map((column: any, index: number) => (
      <option key={index} value={column.value}>
        {column.value}
      </option>
    ));
  };

  const itemOptions = () => {
    let itemsList: ISectionItem[] = [];
    if (selectedSectionId) {
      const selectedSection = getSections().find(s => s.id === selectedSectionId);
      if (selectedSection?.items) {
        itemsList = selectedSection.items
          .filter(i => i.column === selectedColumn)
          .filter(i => i.id !== movingItemId);
      }
    }
    if (itemsList.length < 1) {
      return;
    }

    return itemsList?.map((i) => (
      <option key={i.id} value={`${i.id}`}>
        {i.id}
      </option>
    ));
  };

  const modalButtons = [
    {classes: "cancel", clickHandler: handleCloseDialog, disabled: false, svg: <Close height="12" width="12"/>, text: "Cancel"},
    {classes: "move", clickHandler: handleMoveItem, disabled: !validSection, svg: <Move height="16" width="16"/>, text: "Move"}
  ];

  if (movingItemId) {
    return (
      <Modal title="Move this item to..." visibility={true} closeFunction={handleCloseDialog} width={600}>
        <div className="sectionItemMoveDialog">
          <dl>
            <dt className="col1">Page</dt>
            <dd className="col1">
              <select value={selectedPageId} name="page" onChange={handlePageChange}>
                <option value="">Select ...</option>
                { pagesForPicking.map( (id, index) => (
                    <option key={id} value={id}>{index + 1}</option>
                  ))
                }
              </select>
            </dd>
            <dt className="col2">Section</dt>
            <dd className="col2">
              <select name="section" onChange={handleSectionChange}>
                <option value="">Select ...</option>
                {
                  sections.map((s) => {
                    return <option key={`section-option-${s.id}`} value={s.id}>{s.position}</option>;
                    })
                }
              </select>
            </dd>
            <dt className="col3">Column</dt>
            <dd className="col3">
              <select name="column" onChange={handleColumnChange}>
                {columnOptions()}
              </select>
            </dd>
            <dt className="col4">Position</dt>
            <dd className="col4">
            <select name="position" onChange={handlePositionChange}>
                <option value={RelativeLocation.After}>{RelativeLocation.After}</option>
                <option value={RelativeLocation.Before}>{RelativeLocation.Before}</option>
              </select>
            </dd>
            <dt className="col5">Item</dt>
            <dd className="col5">
              <select name="otherItem" onChange={handleOtherItemChange}>
                <option value="">Select one...</option>
                {itemOptions()}
              </select>
            </dd>
          </dl>
          <ModalButtons buttons={modalButtons} />
        </div>
      </Modal>
    );
  }
  return null;
};
