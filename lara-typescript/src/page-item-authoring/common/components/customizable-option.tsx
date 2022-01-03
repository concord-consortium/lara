import * as React from "react";

interface Props {
  label: string;
  inheritName: string;
  customName: string;
  inherit: boolean;
  defaultLabel: string;
  onChange: (inherit: boolean) => void;
}

export const CustomizableOption: React.FC<Props> = (props) => {
  const {label, inheritName, customName, inherit, defaultLabel, onChange, children} = props;

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    onChange(!!(e.target.checked && (e.target.value === "1")));
  };

  return (
    <>
      <div className="customizable-label">{label}</div>
      <div className="customizable-option">
        <input
          type="radio"
          id={inheritName}
          name={inheritName}
          value="1"
          checked={inherit}
          onChange={handleChange}
        />
        <label htmlFor={inheritName} className="radioLabel">
          Use default: <strong>{defaultLabel}</strong>
        </label>
      </div>
      <div className="customizable-option">
        <input
          type="radio"
          id={inheritName}
          name={inheritName}
          value="0"
          checked={!inherit}
          onChange={handleChange}
        />
        <label htmlFor={inheritName} className="radioLabel">
          Customize
        </label>
        {!inherit && children}
      </div>
    </>
  );
};
