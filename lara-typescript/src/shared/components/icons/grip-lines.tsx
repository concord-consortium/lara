import * as React from "react";

const kDefaultHeight = "1em";

export interface IGripLinesProps {
  height?: string;
}

export const GripLines = (props: IGripLinesProps) => {
  const height = props.height ? props.height : kDefaultHeight;

  return(
    <svg
      aria-hidden="true"
      focusable="false"
      role="img"
      height={height}
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 512 512">
        <path
          fill="currentColor"
          d="M496 288H16c-8.8 0-16 7.2-16 16v32c0 8.8 7.2 16 16 16h480c8.8 0 16-7.2 16-16v-32c0-8.8-7.2-16-16-16zm0-128H16c-8.8 0-16 7.2-16 16v32c0 8.8 7.2 16 16 16h480c8.8 0 16-7.2 16-16v-32c0-8.8-7.2-16-16-16z"/>
      </svg>
  );
};
