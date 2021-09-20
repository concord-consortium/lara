import * as React from "react";

const kDefaultHight = "1em";
const kDefaultWidth = "1em";

export interface ICompletionProps {
  height?: string;
  width?: string;
}

export const Completion = (props: ICompletionProps) => {
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
      <path d="M15 3H5c-1.1 0-1.99.9-1.99 2L3 19c0 1.1.89 2 1.99 2H19c1.1 0 2-.9 2-2V9l-6-6zM8 17c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm0-4c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm0-4c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm6 1V4.5l5.5 5.5H14z" transform="translate(-704 -183) translate(40 163) translate(654 10) translate(10 10)"/>
    </svg>
  );
};