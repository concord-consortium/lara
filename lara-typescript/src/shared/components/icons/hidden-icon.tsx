import * as React from "react";

const kDefaultHeight = "1em";
const kDefaultWidth = "1em";

export interface IHiddenIconProps {
  height?: string;
  width?: string;
}

export const HiddenIcon = (props: IHiddenIconProps) => {
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
      viewBox="0 0 30 26"
      xmlns="http://www.w3.org/2000/svg">
      <path d="M30,13c0,1.11-6,10-15,10a13.83,13.83,0,0,1-1.83-.13l.91-1.93A7,7,0,0,0,15,21,8,8,0,0,0,20.51,7.21l1.18-2.52C26.84,7.32,30,12.2,30,13ZM15,19h0a6,6,0,0,0,4.6-9.85ZM21.5,1.56l-11,23.54L7.7,23.81l1.06-2.28C3.34,19,0,13.83,0,13,0,11.89,6,3,15,3a13.66,13.66,0,0,1,2.34.22l1.39-3ZM9.89,19.13l.88-1.88a6,6,0,0,1-.37-8.09A2.49,2.49,0,0,0,12.5,13l.28,0,1.8-3.85a2.47,2.47,0,0,0-3.42-.72A6,6,0,0,1,15,7a4.89,4.89,0,0,1,.55,0l.9-1.91A7.75,7.75,0,0,0,15,5,8,8,0,0,0,9.89,19.13Z"/>
    </svg>
  );
};