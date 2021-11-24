import * as React from "react";

const kDefaultHeight = "32";
const kDefaultWidth = "32";

export interface IMenuIconProps {
  height?: string;
  width?: string;
}

export const MenuIcon = (props: IMenuIconProps) => {
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
      <path d="M4 24h24v-2.667H4V24zm0-6.667h24v-2.666H4v2.666zm0 0h24v-2.666H4v2.666zM4 8v2.667h24V8H4z"/>
    </svg>
  );
};
