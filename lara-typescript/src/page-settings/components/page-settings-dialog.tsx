import * as React from "react";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { Save } from "../../shared/components/icons/save-icon";
import { Close } from "../../shared/components/icons/close-icon";

import "./page-settings-dialog.scss";

export interface IPageSettingsDialogProps {
  title: string | undefined;
  isHidden?: boolean;
  isCompletion?: boolean;
  hasArgBlock?: boolean;
  hasStudentSidebar?: boolean;
  hasTESidebar?: boolean;
  updateSettingsFunction: (
    updatedTitle: string | undefined,
    updatedIsCompletion: boolean,
    updatedIsHidden: boolean,
    updatedHasArgBlock: boolean,
    updatedHasStudentSidebar: boolean,
    updatedHasTESidebar: boolean
  ) => void;
  closeDialogFunction: () => void;
}

export const PageSettingsDialog: React.FC<IPageSettingsDialogProps> = ({
  title,
  isHidden = false,
  isCompletion = false,
  hasArgBlock = false,
  hasStudentSidebar = false,
  hasTESidebar = false,
  updateSettingsFunction,
  closeDialogFunction
  }: IPageSettingsDialogProps) => {

  const [argBlockSettingEnabled, setargBlockSettingEnabled] = React.useState(false);
  const [studentSidebarSettingEnabled, setstudentSidebarSettingEnabled] = React.useState(false);
  const [teSidebarSettingEnabled, setTESidebarSettingEnabled] = React.useState(false);

  const handleTitleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    title = event.target.value;
  };

  const handleIsCompletionChange = () => {
    isCompletion = !isCompletion;
  };

  const handleIsHiddenChange = () => {
    isHidden = !isHidden;
  };

  const handleHasArgBlockChange = () => {
    hasArgBlock = !hasArgBlock;
  };

  const handleHasStudentSidebarChange = () => {
    hasStudentSidebar = !hasStudentSidebar;
  };

  const handleHasTESidebarChange = () => {
    hasTESidebar = !hasTESidebar;
  };

  const handleUpdateSettings = () => {
    updateSettingsFunction(
      title,
      isCompletion,
      isHidden,
      hasArgBlock,
      hasStudentSidebar,
      hasTESidebar
    );
  };

  const handleCloseDialog = () => {
    closeDialogFunction();
  };

  const modalButtons = [
    {classes: "cancel", clickHandler: handleCloseDialog, disabled: false, svg: <Close height="12" width="12"/>, text: "Cancel"},
    {classes: "copy", clickHandler: handleUpdateSettings, disabled: false, svg: <Save height="16" width="16"/>, text: "Save & Close"}
  ];

  return (
    <Modal closeFunction={handleCloseDialog} title="Page Settings" visibility={true}>
      <div className="pageSettingsDialog">
        <dl>
          <dt className="input1">
            <label htmlFor="pageTitle">Page Title</label>
          </dt>
          <dd className="input1">
            <input
              type="text"
              id="pageTitle"
              name="pageTitle"
              defaultValue={title}
              onChange={handleTitleChange}
              placeholder="Enter a title"
            />
          </dd>
          <dt className="input2">
            <label htmlFor="isHidden">Page is hidden from students</label>
          </dt>
          <dd className="input2">
            <input
              type="checkbox"
              id="isHidden"
              name="isHidden"
              defaultChecked={isHidden}
              onChange={handleIsHiddenChange}
            />
          </dd>
          <dt className="input3">
            <label htmlFor="isCompletion">Page is a completion/summary page</label>
          </dt>
          <dd className="input3">
            <input
              type="checkbox"
              id="isCompletion"
              name="isCompletion"
              defaultChecked={isCompletion}
              onChange={handleIsCompletionChange}
            />
          </dd>
          <dt className={`input4 ${argBlockSettingEnabled ? "" : "disabled"}`}>
            <label htmlFor="hasArgBlock">Page has an argumentation block</label>
          </dt>
          <dd className={`input4 ${argBlockSettingEnabled ? "" : "disabled"}`}>
            <input
              type="checkbox"
              id="hasArgBlock"
              name="hasArgBlock"
              defaultChecked={hasArgBlock}
              onChange={handleHasArgBlockChange}
            />
          </dd>
          <dt className={`input5 ${studentSidebarSettingEnabled ? "" : "disabled"}`}>
            <label htmlFor="hasStudentSidebar">Page has a student sidebar menu</label>
          </dt>
          <dd className={`input5 ${studentSidebarSettingEnabled ? "" : "disabled"}`}>
            <input
              type="checkbox"
              id="hasStudentSidebar"
              name="hasStudentSidebar"
              defaultChecked={hasStudentSidebar}
              onChange={handleHasStudentSidebarChange}
            />
          </dd>
          <dt className={`input6 ${teSidebarSettingEnabled ? "" : "disabled"}`}>
            <label htmlFor="hasTESidebar">Page has a Teacher Edition sidebar menu</label>
          </dt>
          <dd className={`input6 ${teSidebarSettingEnabled ? "" : "disabled"}`}>
            <input
              type="checkbox"
              id="hasTESidebar"
              name="hasTESidebar"
              defaultChecked={hasTESidebar}
              onChange={handleHasTESidebarChange}
            />
          </dd>
        </dl>
        <ModalButtons buttons={modalButtons} />
      </div>
    </Modal>
  );
};
