import * as React from "react";

const kDefaultHeight = "1em";
const kDefaultWidth = "1em";

export interface ISaveProps {
  height?: string;
  width?: string;
}

export const Save = (props: ISaveProps) => {
  const height = props.height ? props.height : kDefaultHeight;
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
      viewBox="0 0 20 20"
      xmlns="http://www.w3.org/2000/svg">
      <g>
        <path d="M15.173 2H4c-1.101 0-2 .9-2 2v12c0 1.1.899 2 2 2h12c1.101 0 2-.9 2-2V5.127L15.173 2zM14 8c0 .549-.45 1-1 1H7c-.55 0-1-.451-1-1V3h8v5zm-1-4h-2v4h2V4z"/>
      </g>
    </svg>
  );
};
