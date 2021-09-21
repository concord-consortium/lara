import React, { useState } from "react";
import { ISectionProps } from "./authoring-section";
import { ISectionItemProps } from "./section-item";
import "./section-item-move-dialog.css";

export interface ISectionItemMoveDialogProps {
  item: ISectionItemProps;
  sections: ISectionProps[];
  selectedPageId?: string;
  selectedSectionId?: string;
  selectedColumn?: number;
  selectedPosition?: string;
  selectedOtherItemId?: string | undefined;
  moveItemFunction: (itemId: string, selectedPageId: string, selectedSectionId: string, selectedColumn: number, selectedPosition: string, selectedOtherItemId: string) => void;
  closeDialogFunction: () => void;
}

export const SectionItemMoveDialog: React.FC<ISectionItemMoveDialogProps> = ({
  item,
  sections,
  selectedPageId = "0",
  selectedSectionId: initSelectedSectionId = "1",
  selectedColumn: initSelectedColumn = 0,
  selectedPosition = "after",
  selectedOtherItemId: initSelectedOtherItemId = "0",
  moveItemFunction,
  closeDialogFunction
  }: ISectionItemMoveDialogProps) => {

  const [selectedSectionId, setSelectedSectionId] = useState(initSelectedSectionId);
  const [selectedColumn, setSelectedColumn] = useState(initSelectedColumn);
  const [selectedOtherItemId, setSelectedOtherItemId] = useState(initSelectedOtherItemId);

  const handlePageChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    selectedPageId = change.target.value;
  };

  const handleSectionChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedSectionId(change.target.value);
  };

  const handleColumnChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedColumn(parseInt(change.target.value));
  };

  const handlePositionChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    selectedPosition = change.target.value;
  };

  const handleOtherItemChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    const [sectionId, otherItemId] = change.target.value.split("--");
    setSelectedSectionId(sectionId);
    setSelectedOtherItemId(otherItemId);
  };

  const handleCloseDialog = () => {
    closeDialogFunction();
  };

  const handleMoveItem = () => {
    moveItemFunction(item.id, selectedPageId, selectedSectionId, selectedColumn, selectedPosition, selectedOtherItemId);
    closeDialogFunction();
  };

  const columnOptions = () => {
    let columnCount = 1;
    const options: any = [{value: columnCount}];
    if (selectedSectionId) {
      const section = sections.find(s => s.id === selectedSectionId);
      if (section?.layout !== "Full Width") {
        ++columnCount;
        options.push({value: columnCount});
      }
    }
    return options.map((column: any, index: number) => (
      <option key={index} value={index}>
        {column.value}
      </option>
    ));
  };

  const itemOptions = () => {
    let itemsList: ISectionItemProps[] = [];
    if (selectedSectionId) {
      const selectedSection = sections.find(s => s.id === selectedSectionId);
      if (selectedSection?.items) {
        itemsList = selectedSection.items.filter(i => i.id !== item.id && i.section_col === selectedColumn);
      }
    }
    if (itemsList.length < 1) {
      return;
    }

    return itemsList?.map((i) => (
      <option key={i.id} value={`${i.section_id}--${i.id}`}>
        Section {`${i.section_id}, ${i.title}`}
      </option>
    ));
  };

  return (
    <>
      <div className="modalOverlay"/>
      <div className="modal sectionItemMoveDialog">
        <header>
          <h1>Move this item to...</h1>
          <button className="modalClose" onClick={handleCloseDialog}>close</button>
        </header>
        <section>
          <form>
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
                  {
                    sections.map(s => (
                      <option key={s.id} value={s.id}>
                        {s.id}
                      </option>
                    ))
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
            <div className="actionButtons">
              <button className="cancel" onClick={handleCloseDialog}>Cancel</button>
              <button className="move" onClick={handleMoveItem}>Move</button>
            </div>
          </form>
        </section>
      </div>
    </>
  );
};
