import * as React from "react";

interface Props {
  legend?: string;
  value: any;
  inherit?: boolean;
  inherited?: boolean;
  inheritedValue?: any;
}

export const ReadOnlyFormField: React.FC<Props> = ({ legend, value, inherit, inherited, inheritedValue, children }) => {

  const renderValue = () => {
    const renderedValue = inherit
      ? (inherited ? `${inheritedValue} (inherited)` : `${value} (customized)`)
      : value;
    return (
      <>
        {renderedValue}
        {children}
      </>
    );
  };

  if (typeof legend !== undefined) {
    return (
      <fieldset>
        <legend>{legend}</legend>
        {renderValue()}
      </fieldset>
    );
  }

  return renderValue();
};
