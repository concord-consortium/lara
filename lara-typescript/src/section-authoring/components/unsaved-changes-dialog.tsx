import * as React from "react";
import "./unsaved-changes-dialog.scss";

interface IProps {
  onCancel: () => void;
  onConfirm: () => void;
}

export const UnsavedChangesDialog: React.FC<IProps> = ({onCancel, onConfirm}) => {
  return (
    <div className="unsaved-changes-dialog-backdrop">
      <div
        aria-describedby="unsaved-changes-message"
        aria-labelledby="unsaved-changes-title"
        aria-modal="true"
        className="unsaved-changes-dialog"
        role="dialog"
      >
        <div className="unsaved-changes-dialog-header">
          <h2 id="unsaved-changes-title" className="unsaved-changes-dialog-title">
            Unsaved Changes
          </h2>
        </div>
        <div className="unsaved-changes-dialog-body">
          <p id="unsaved-changes-message" className="unsaved-changes-dialog-message">
            You have unsaved changes that will be lost if you continue. Do you want to continue?
          </p>
        </div>
        <div className="unsaved-changes-dialog-footer">
          <button
            className="unsaved-changes-dialog-button unsaved-changes-dialog-button--cancel"
            type="button"
            onClick={onCancel}
          >
            Cancel
          </button>
          <button
            className="unsaved-changes-dialog-button unsaved-changes-dialog-button--confirm"
            type="button"
            onClick={onConfirm}
          >
            Continue Without Saving
          </button>
        </div>
      </div>
    </div>
  );
};
