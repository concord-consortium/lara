import * as React from "react";
import { useState } from "react";
import { ISectionItem, ISection, SectionColumns } from "../api/api-types";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { Close } from "../../shared/components/icons/close-icon";
import { Move } from "../../shared/components/icons/move-icon";
import { usePageAPI } from "../api/use-api-provider";
import { UserInterfaceContext } from "../api/use-user-interface-context";

import "./section-item-move-dialog.scss";

export interface ISectionItemMoveDialogProps {
  sections: ISection[];
  selectedPageId?: string;
  selectedSectionId?: string;
  selectedColumn?: SectionColumns;
  selectedPosition?: string;
  selectedOtherItemId?: string | undefined;
}

export const SectionItemMoveDialog: React.FC<ISectionItemMoveDialogProps> = ({
  sections,
  selectedPageId = "0",
  selectedSectionId: initSelectedSectionId = "1",
  selectedColumn: initSelectedColumn = SectionColumns.PRIMARY,
  selectedPosition: initSelectedPosition = "after",
  selectedOtherItemId: initSelectedOtherItemId = "0",
  }: ISectionItemMoveDialogProps) => {
  const [selectedSectionId, setSelectedSectionId] = useState(initSelectedSectionId);
  const [selectedColumn, setSelectedColumn] = useState(initSelectedColumn);
  const [selectedPosition, setSelectedPosition] = useState(initSelectedPosition);
  const [selectedOtherItemId, setSelectedOtherItemId] = useState(initSelectedOtherItemId);
  const [modalVisibility, setModalVisibility] = useState(true);

  const { moveItem, getSections } = usePageAPI();
  const { userInterface: {movingItemId}, actions: {setMovingItemId}} = React.useContext(UserInterfaceContext);

  const handlePageChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    selectedPageId = change.target.value;
  };

  const handleSectionChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedSectionId(change.target.value);
  };

  const handleColumnChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedColumn(change.target.value as SectionColumns);
  };

  const handlePositionChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedPosition(change.target.value);
  };

  const handleOtherItemChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedOtherItemId(change.target.value);
  };

  const handleCloseDialog = () => {
    setMovingItemId(false);
  };

  const handleMoveItem = () => {
    if (movingItemId) {
      moveItem(movingItemId, selectedSectionId, selectedColumn, selectedPosition, selectedOtherItemId);
    }
    handleCloseDialog();
  };

  const columnOptions = () => {
    const options: any = [{value: SectionColumns.PRIMARY}];
    if (selectedSectionId) {
      const section = sections.find(s => s.id === selectedSectionId);
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
      const selectedSection = sections.find(s => s.id === selectedSectionId);
      if (selectedSection?.items) {
        itemsList = selectedSection.items.filter(i => i.id !== movingItemId && i.column === selectedColumn);
      }
    }
    if (itemsList.length < 1) {
      return;
    }

    return itemsList?.map((i) => (
      <option key={i.id} value={`${i.id}`}>
        {i.title}
      </option>
    ));
  };

  const modalButtons = [
    {classes: "cancel", clickHandler: handleCloseDialog, disabled: false, svg: <Close height="12" width="12"/>, text: "Cancel"},
    {classes: "move", clickHandler: handleMoveItem, disabled: false, svg: <Move height="16" width="16"/>, text: "Move"}
  ];

  if (movingItemId) {
    return (
      <Modal title="Move this item to..." visibility={modalVisibility} width={600}>
        <div className="sectionItemMoveDialog">
          <dl>
            <dt className="col1">Page</dt>
            <dd className="col1">
              <select name="page" onChange={handlePageChange}>
                <option value="1">1</option>
              </select>
            </dd>
            <dt className="col2">Section</dt>
            <dd className="col2">
              <select name="section" onChange={handleSectionChange}>
                {sections.map((s) => {
                    return <option key={`section-option-${s.id}`} value={s.id}>{s.id}</option>;
                  })}
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
                <option value="after">After</option>
                <option value="before">Before</option>
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
