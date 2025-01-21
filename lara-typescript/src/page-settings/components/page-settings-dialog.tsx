import * as React from "react";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { Save } from "../../shared/components/icons/save-icon";
import { Close } from "../../shared/components/icons/close-icon";
import { IPage } from "../../section-authoring/api/api-types";

import "./page-settings-dialog.scss";

export interface IPageSettingsDialogProps {
  name: string | undefined;
  isHidden?: boolean;
  isCompletion?: boolean;
  hasStudentSidebar?: boolean;
  disableCompletionPageSetting?: string | boolean;
  updateSettingsFunction: (changes: Partial<IPage>) => void;
  closeDialogFunction: () => void;
}

export const PageSettingsDialog: React.FC<IPageSettingsDialogProps> = ({
  name,
  isHidden = false,
  isCompletion = false,
  hasStudentSidebar = false,
  disableCompletionPageSetting,
  updateSettingsFunction,
  closeDialogFunction
  }: IPageSettingsDialogProps) => {

  const disableCompletionPageSettingReason = disableCompletionPageSetting ? disableCompletionPageSetting : null;

  const [currentName, setCurrentName] = React.useState(name);
  const [hasStudentSidebarPage, setHasStudentSidebarPage] = React.useState(hasStudentSidebar);
  const [isCompletionPage, setIsCompletionPage] = React.useState(isCompletion);
  const [isCompletionDisabled, setIsCompletionDisabled] = React.useState(!!disableCompletionPageSetting);
  const [isHiddenPage, setIsHiddenPage] = React.useState(isHidden);
  const [isHiddenDisabled, setIsHiddenDisabled] = React.useState(isCompletion);

  React.useEffect(() => {
    setIsHiddenDisabled(isCompletionPage);
    if (!disableCompletionPageSetting) {
      setIsCompletionDisabled(isHiddenPage);
    }
  }, [isCompletionPage, isHiddenPage]);

  const handleNameChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setCurrentName(event.target.value);
  };

  const handleIsCompletionChange = () => {
    const newIsCompletion = !isCompletionPage;
    setIsCompletionPage(newIsCompletion);
    if (newIsCompletion) {
      setHasStudentSidebarPage(false);
    }
  };

  const handleIsHiddenChange = () => {
    setIsHiddenPage(!isHiddenPage);
  };

  const handleHasStudentSidebarChange = () => {
    setHasStudentSidebarPage(!hasStudentSidebarPage);
  };

  const handleUpdateSettings = () => {
    updateSettingsFunction({
      name: currentName,
      isCompletion: isCompletionPage,
      isHidden: isHiddenPage,
      showSidebar: hasStudentSidebarPage
    });
  };

  const handleCloseDialog = () => {
    closeDialogFunction();
  };

  const modalButtons = [
    {"classes": "cancel", "clickHandler": handleCloseDialog, "disabled": false, "svg": <Close height="12" width="12"/>, "text": "Cancel", "data-testid": "cancel-button-page-settings"},
    {"classes": "copy", "clickHandler": handleUpdateSettings, "disabled": false, "svg": <Save height="16" width="16"/>, "text": "Save & Close", "data-testid": "save-and-close-button-page-settings"}
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
              value={currentName}
              onChange={handleNameChange}
              placeholder="Enter a title"
              data-testid="page-title-input"
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
              checked={isHiddenPage}
              onChange={handleIsHiddenChange}
            />
          </dd>
          <dt className={`input3 ${isCompletionDisabled && "disabled"}`}>
            <label htmlFor="isCompletion">
              Page is a completion/summary page { disableCompletionPageSettingReason && `(${disableCompletionPageSettingReason})` }
            </label>
          </dt>
          <dd className={`input3 ${isCompletionDisabled && "disabled"}`}>
            <input
              type="checkbox"
              id="isCompletion"
              disabled={isCompletionDisabled}
              name="isCompletion"
              checked={isCompletionPage}
              onChange={handleIsCompletionChange}
            />
          </dd>
          <dt className={`input5 ${isCompletionPage && "disabled"}`}>
            <label htmlFor="hasStudentSidebar">Page has a student sidebar menu</label>
          </dt>
          <dd className={`input5 ${isCompletionPage && "disabled"}`}>
            <input
              type="checkbox"
              id="hasStudentSidebar"
              disabled={isCompletionPage}
              name="hasStudentSidebar"
              checked={hasStudentSidebarPage}
              onChange={handleHasStudentSidebarChange}
            />
          </dd>
        </dl>
        <ModalButtons buttons={modalButtons} />
      </div>
    </Modal>
  );
};
