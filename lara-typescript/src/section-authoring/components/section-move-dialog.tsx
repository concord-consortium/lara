import * as React from "react";
import { useState } from "react";
import { ISectionProps } from "./authoring-section";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { Close } from "../../shared/components/icons/close-icon";
import { Move } from "../../shared/components/icons/move-icon";

import "./section-move-dialog.scss";
import { usePageAPI } from "../hooks/use-api-provider";
import { UserInterfaceContext } from "../containers/user-interface-provider";
import { ISectionDestination, RelativeLocation } from "../util/move-utils";

export interface ISectionMoveDialogProps {
  sections: ISectionProps[];
}

export const SectionMoveDialog: React.FC<ISectionMoveDialogProps> = ({sections
  }: ISectionMoveDialogProps) => {
  const { userInterface: { movingSectionId }, actions: {setMovingSectionId}} = React.useContext(UserInterfaceContext);
  const { moveSection, currentPage } = usePageAPI();
  const [selectedOtherSectionId, setSelectedOtherSectionId] = useState("");
  const [selectedPageId, setSelectedPageId] = useState(currentPage?.id || "");
  const [selectedPosition, setSelectedPosition] = useState(RelativeLocation.After);

  const handlePageChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedPageId(change.target.value);
  };

  const handlePositionChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedPosition(change.target.value as RelativeLocation);
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
      const destination: ISectionDestination = {
        relativeLocation: selectedPosition,
        destPageId: selectedPageId,
        destSectionId: selectedOtherSectionId
      };
      moveSection(movingSectionId, destination);
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
      <Modal title={`Move section ${movingSectionId} to...`}
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
