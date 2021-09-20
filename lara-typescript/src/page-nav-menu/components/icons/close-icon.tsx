import * as React from "react";

const kDefaultHight = "1em";
const kDefaultWidth = "1em";

export interface ICloseProps {
  height?: string;
  width?: string;
}

export const Close = (props: ICloseProps) => {
  const height = props.height ? props.height : kDefaultHight;
  const width = props.width ? props.width : kDefaultWidth;

  return(
    <svg
      aria-hidden={true}
      className="icon"
      fill="white"
      focusable="false"
      height={height}
      width={width}
      role="img"
      viewBox="0 0 8.38 8.39"
      xmlns="http://www.w3.org/2000/svg">
      <polygon points="8.38 2.02 6.36 0 4.18 2.17 2.02 0.01 0 2.04 2.16 4.2 0 6.35 2.02 8.38 4.18 6.22 6.36 8.39 8.38 6.37 6.21 4.2 8.38 2.02"/>
    </svg>
  );
};
