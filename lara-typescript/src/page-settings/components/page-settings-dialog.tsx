import * as React from "react";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { Save } from "../../shared/components/icons/save-icon";
import { Close } from "../../shared/components/icons/close-icon";

import "./page-settings-dialog.scss";

export interface IPageSettingsDialogProps {
  name: string | undefined;
  isHidden?: boolean;
  isCompletion?: boolean;
  hasArgBlock?: boolean;
  hasStudentSidebar?: boolean;
  hasTESidebar?: boolean;
  disableCompletionPageSetting?: boolean;
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
  name,
  isHidden = false,
  isCompletion = false,
  hasArgBlock = false,
  hasStudentSidebar = false,
  hasTESidebar = false,
  disableCompletionPageSetting,
  updateSettingsFunction,
  closeDialogFunction
  }: IPageSettingsDialogProps) => {

  const [argBlockSettingEnabled, setargBlockSettingEnabled] = React.useState(false);
  const [studentSidebarSettingEnabled, setstudentSidebarSettingEnabled] = React.useState(false);
  const [teSidebarSettingEnabled, setTESidebarSettingEnabled] = React.useState(false);
  const [isCompletionPage, setIsCompletionPage] = React.useState(isCompletion);
  const [isCompletionDisabled, setIsCompletionDisabled] = React.useState(disableCompletionPageSetting);
  const [isHiddenPage, setIsHiddenPage] = React.useState(isHidden);
  const [isHiddenDisabled, setIsHiddenDisabled] = React.useState(isCompletion);

  React.useEffect(() => {
    setIsHiddenDisabled(isCompletionPage);
    if (!disableCompletionPageSetting) {
      setIsCompletionDisabled(isHiddenPage);
    }
  }, [isCompletionPage, isHiddenPage]);

  const handleTitleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    name = event.target.value;
  };

  const handleIsCompletionChange = () => {
    setIsCompletionPage(!isCompletionPage);
  };

  const handleIsHiddenChange = () => {
    setIsHiddenPage(!isHiddenPage);
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
      name,
      isCompletionPage,
      isHiddenPage,
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
              defaultValue={name}
              onChange={handleTitleChange}
              placeholder="Enter a title"
            />
          </dd>
          <dt className={`input2 ${isHiddenDisabled && "disabled"}`}>
            <label htmlFor="isHidden">Page is hidden from students</label>
          </dt>
          <dd className={`input2 ${isHiddenDisabled && "disabled"}`}>
            <input
              type="checkbox"
              id="isHidden"
              name="isHidden"
              defaultChecked={isHiddenPage}
              onChange={handleIsHiddenChange}
            />
          </dd>
          <dt className={`input3 ${isCompletionDisabled && "disabled"}`}>
            <label htmlFor="isCompletion">
              Page is a completion/summary page (An activity can only have one completion page)
            </label>
          </dt>
          <dd className={`input3 ${isCompletionDisabled && "disabled"}`}>
            <input
              type="checkbox"
              id="isCompletion"
              name="isCompletion"
              defaultChecked={isCompletionPage}
              onChange={handleIsCompletionChange}
            />
          </dd>
          {/* TODO: Reinstate this option if/when we add support for
              arg blocks.
          <dt className={`input4 ${!argBlockSettingEnabled && "disabled"}`}>
            <label htmlFor="hasArgBlock">Page has an argumentation block</label>
          </dt>
          <dd className={`input4 ${!argBlockSettingEnabled && "disabled"}`}>
            <input
              type="checkbox"
              id="hasArgBlock"
              name="hasArgBlock"
              defaultChecked={hasArgBlock}
              onChange={handleHasArgBlockChange}
            />
          </dd> */}
          <dt className={`input5 ${!studentSidebarSettingEnabled}`}>
            <label htmlFor="hasStudentSidebar">Page has a student sidebar menu</label>
          </dt>
          <dd className={`input5 ${!studentSidebarSettingEnabled}`}>
            <input
              type="checkbox"
              id="hasStudentSidebar"
              name="hasStudentSidebar"
              defaultChecked={hasStudentSidebar}
              onChange={handleHasStudentSidebarChange}
            />
          </dd>
          {/* TODO: Reinstate this option if/when we update how
              TE sidebars are handled. For now they are added
              like any other page item.
          <dt className={`input6 ${!teSidebarSettingEnabled && "disabled"}`}>
            <label htmlFor="hasTESidebar">Page has a Teacher Edition sidebar menu</label>
          </dt>
          <dd className={`input6 ${!teSidebarSettingEnabled && "disabled"}`}>
            <input
              type="checkbox"
              id="hasTESidebar"
              name="hasTESidebar"
              defaultChecked={hasTESidebar}
              onChange={handleHasTESidebarChange}
            />
          </dd> */}
        </dl>
        <ModalButtons buttons={modalButtons} />
      </div>
    </Modal>
  );
};
