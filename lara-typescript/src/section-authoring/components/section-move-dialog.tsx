import * as React from "react";
import { IPage } from "../api/api-types";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { Close } from "../../shared/components/icons/close-icon";
import { Move } from "../../shared/components/icons/move-icon";
import { usePageAPI } from "../hooks/use-api-provider";
import { UserInterfaceContext } from "../containers/user-interface-provider";
import { ISectionDestination } from "../util/move-utils";
import { useDestinationChooser } from "../hooks/use-destination-chooser";
import { sectionName } from "../util/sections";

import "./section-move-dialog.scss";

export const SectionMoveDialog: React.FC = () => {
  const { userInterface: { movingSectionId }, actions: { setMovingSectionId }} = React.useContext(UserInterfaceContext);
  const { moveSection, currentPage } = usePageAPI();
  const {
    sections, selectedSectionId,
    pagesForPicking, handlePageChange, selectedPageId, validPage,
    handlePositionChange, selectedPosition,
    handleSectionChange
  } = useDestinationChooser();

  const handleCloseDialog = () => {
    setMovingSectionId(false);
  };

  const handleMoveSection = () => {
    if (movingSectionId) {
      const destination: ISectionDestination = {
        relativeLocation: selectedPosition,
        destPageId: selectedPageId,
        destSectionId: selectedSectionId
      };
      moveSection(movingSectionId, destination);
    }
    handleCloseDialog();
  };

  const sectionOptions = () => {
    const sectionsList = sections.filter(s => s.id !== movingSectionId);
    if (sectionsList.length < 1) {
      return;
    }
    return sectionsList?.map((s) => (
      <option key={s.id} value={`${s.id}`}>
        {sectionName(s)}
      </option>
    ));
  };

  const movingSectionPosition = () => {
    const currentPageSections = currentPage && currentPage.sections;
    const sectionToMove =  currentPageSections && currentPageSections.find(s => s.id === movingSectionId);
    if (sectionToMove?.name) {
      return sectionToMove.name;
    }
    return `Section ${sectionToMove?.position}`;
  };

  const modalButtons = [
    {classes: "cancel", clickHandler: handleCloseDialog, disabled: false, svg: <Close height="12" width="12"/>, text: "Cancel"},
    {classes: "move", clickHandler: handleMoveSection, disabled: !validPage, svg: <Move height="16" width="16"/>, text: "Move"}
  ];

  if (movingSectionId) {
    return (
      <Modal title={`Move ${movingSectionPosition()} to...`}
        visibility={true} width={600} closeFunction={handleCloseDialog}>
        <div className="sectionMoveDialog">
          <dl>
            <dt className="col1">Page</dt>
            <dd className="col1">
              <select value={selectedPageId} name="page" onChange={handlePageChange}>
                <option >Select ...</option>
                { pagesForPicking.map( (p: Partial<IPage>, index: number) => (
                    !p.isCompletion && <option key={p.id} value={p.id}>{index + 1}{p.isHidden && ` (hidden)`}</option>
                  ))
                }

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
              <select name="otherItem" onChange={handleSectionChange}>
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
