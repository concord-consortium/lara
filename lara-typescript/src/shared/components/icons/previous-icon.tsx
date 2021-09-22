import * as React from "react";

const kDefaultHight = "1em";
const kDefaultWidth = "1em";

export interface IPreviousProps {
  height?: string;
  width?: string;
}

export const Previous = (props: IPreviousProps) => {
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
      viewBox="0 0 24 24"
      xmlns="http://www.w3.org/2000/svg">
      <path d="M15.67 3.87L13.9 2.1 4 12l9.9 9.9 1.77-1.77L7.54 12z"/>
    </svg>
  );
};
