import * as React from "react";

const kDefaultHeight = "32";
const kDefaultWidth = "32";

export interface IMenuCloseIconProps {
  height?: string;
  width?: string;
}

export const MenuCloseIcon = (props: IMenuCloseIconProps) => {
  const height = props.height ? props.height : kDefaultHeight;
  const width = props.width ? props.width : kDefaultWidth;

  return (
    <svg
      aria-hidden={true}
      className="icon"
      focusable="false"
      height={height}
      width={width}
      role="img"
      viewBox="0 0 32 32"
      xmlns="http://www.w3.org/2000/svg">
      <path d="M8.458 25.428l16.97-16.97-1.886-1.886-16.97 16.97 1.886 1.886zM6.572 8.458l16.97 16.97 1.886-1.886-16.97-16.97-1.886 1.886z"/>
    </svg>
  );
};
