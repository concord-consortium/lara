import * as React from "react";

interface Props {
  id?: string;
  name: string;
  checked?: boolean;
  defaultChecked?: boolean;
  label: string;
  warning?: string;
  onChange?: (checked: boolean) => void;
}

export const Checkbox: React.FC<Props> = (props) => {
  const {id, name, checked, defaultChecked, label, warning, onChange} = props;

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (onChange) {
      onChange(e.target.checked);
    }
  };

  const renderWarning = () => {
    if (warning !== undefined) {
      return (
        <div className="warning">
          <em>Warning</em>: {warning}
        </div>
      );
    }
  };

  // note: the hidden 0 is to save the checkbox as unchecked
  // as the unchecked checkbox input is not sent in the form data.
  return (
    <>
      <input type="hidden" name={name} value="0" />
      <input
        type="checkbox"
        id={id}
        name={name}
        value="1"
        checked={checked}
        defaultChecked={defaultChecked}
        onChange={handleChange}
        /> {label}
      {renderWarning()}
    </>
  );
};
