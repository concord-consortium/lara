import * as React from "react";
import { useState } from "react";
import { ISectionProps } from "./authoring-section";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { Close } from "../../shared/components/icons/close-icon";
import { Move } from "../../shared/components/icons/move-icon";

import "./section-move-dialog.scss";
import { usePageAPI } from "../api/use-api-provider";
import { UserInterfaceContext } from "../api/use-user-interface-context";

export interface ISectionMoveDialogProps {
  sections: ISectionProps[];
  selectedPageId?: string;
  selectedPosition?: string;
  selectedOtherSectionId?: string | undefined;
}

export const SectionMoveDialog: React.FC<ISectionMoveDialogProps> = ({
  sections,
  selectedPageId = "0",
  selectedPosition = "after",
  selectedOtherSectionId: initSelectedOtherSectionId = "0"
  }: ISectionMoveDialogProps) => {
  const [selectedOtherSectionId, setSelectedOtherSectionId] = useState(initSelectedOtherSectionId);

  // TODO: Should we remove sections from the property list too?
  const { moveSection } = usePageAPI();
  const { userInterface: {movingSectionId}, actions: {setMovingSectionId}} = React.useContext(UserInterfaceContext);

  const handlePageChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    selectedPageId = change.target.value;
  };

  const handlePositionChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    selectedPosition = change.target.value;
  };

  const handleOtherSectionChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    const otherSectionId = change.target.value;
    setSelectedOtherSectionId(otherSectionId);
  };

  const handleCloseDialog = () => {
    setMovingSectionId(false);
  };

  const handleMoveSection = () => {
    if (movingSectionId) {
      moveSection(movingSectionId, selectedPageId, selectedPosition as "before"|"after", selectedOtherSectionId);
    }
    handleCloseDialog();
  };

  const sectionOptions = () => {
    let sectionsList: ISectionProps[] = [];
    if (selectedPageId) {
      const selectedSection = sections.find(s => s.id === movingSectionId);
      if (selectedSection?.items) {
        sectionsList = sections.filter(s => s.id !== movingSectionId);
      }
    }
    if (sectionsList.length < 1) {
      return;
    }

    return sectionsList?.map((s) => (
      <option key={s.id} value={`${s.id}`}>
        Section {`${s.id} ${s.title ? s.title : ""}`}
      </option>
    ));
  };

  const modalButtons = [
    {classes: "cancel", clickHandler: handleCloseDialog, disabled: false, svg: <Close height="12" width="12"/>, text: "Cancel"},
    {classes: "move", clickHandler: handleMoveSection, disabled: false, svg: <Move height="16" width="16"/>, text: "Move"}
  ];

  if (movingSectionId) {
    return (
      <Modal title="Move this section to..."
        visibility={true} width={600} closeFunction={handleCloseDialog}>
        <div className="sectionMoveDialog">
          <dl>
            <dt className="col1">Page</dt>
            <dd className="col1">
              <select name="page" onChange={handlePageChange}>
                <option value="1">1</option>
              </select>
            </dd>
            <dt className="col2">Position</dt>
            <dd className="col2">
            <select name="position" onChange={handlePositionChange}>
                <option value="after">After</option>
                <option value="before">Before</option>
              </select>
            </dd>
            <dt className="col3">Section</dt>
            <dd className="col3">
              <select name="otherItem" onChange={handleOtherSectionChange}>
                <option value="">Select one...</option>
                {sectionOptions()}
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
