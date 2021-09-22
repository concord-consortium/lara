import * as React from "react";

const kDefaultHight = "1em";
const kDefaultWidth = "1em";

export interface INextProps {
  height?: string;
  width?: string;
}

export const Next = (props: INextProps) => {
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
      <path d="M8.33 20.13l1.77 1.77L20 12l-9.9-9.9-1.77 1.77L16.46 12z"/>
    </svg>
  );
};
