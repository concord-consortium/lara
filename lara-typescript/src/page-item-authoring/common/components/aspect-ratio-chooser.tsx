import * as React from "react";
import { useState } from "react";

export const availableAspectRatios = {
  DEFAULT: "Default aspect ratio, or set by interactive",
  MANUAL: "Manually set the native width & height",
  MAX: "Use all available space for the interactive"
};
export type AspectRatioMode = keyof typeof availableAspectRatios;

export interface IAspectRatioChooserValues {
  width: number;
  height: number;
  mode: AspectRatioMode;
}

interface Props {
  width: number;
  height: number;
  mode: AspectRatioMode;
  onChange: (values: IAspectRatioChooserValues) => void;
}

interface FormattedFieldProps {
  value: number;
  label: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
}

const FormattedField: React.FC<FormattedFieldProps> = ({ value, label, onChange }) => {
  return (
    <div style={{display: "flex", flexDirection: "row", alignItems: "baseline"}}>
      <label style={{textAlign: "right", padding: "0 5px"}}>{label}</label>
      <input style={{width: 50, padding: 5}} type="number" value={value} onChange={onChange} />
    </div>
  );
};

export const AspectRatioChooser: React.FC<Props> = (props) => {
  const [width, setWidth] = useState(props.width);
  const [height, setHeight] = useState(props.height);
  const [mode, setMode] = useState(props.mode);

  const handleSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const newMode = e.target.value as AspectRatioMode;
    setMode(newMode);
    props.onChange({width, height, mode: newMode});
  };
  const handleChangeWidth = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newWidth = parseInt(e.target.value, 10);
    setWidth(newWidth);
    props.onChange({width: newWidth, height, mode});
  };
  const handleChangeHeight = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newHeight = parseInt(e.target.value, 10);
    setHeight(newHeight);
    props.onChange({width, height: newHeight, mode});
  };

  const renderInputs = () => {
    return (
      <>
        <FormattedField value={width} label="Width" onChange={handleChangeWidth} />
        <FormattedField value={height} label="Height" onChange={handleChangeHeight} />
      </>
    );
  };

  return (
    <div className="customizable-option-setting">
      <select defaultValue={mode} onChange={handleSelectChange}>
      {Object.keys(availableAspectRatios).map((key: AspectRatioMode) => {
        const value = availableAspectRatios[key];
        return <option key={key} value={key} label={value}>{value}</option>;
      }
      )}
      </select>
      {mode === "MANUAL" ? renderInputs() : undefined}
    </div>
  );

};
