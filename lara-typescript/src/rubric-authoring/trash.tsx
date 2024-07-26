import * as React from "react";

export const Trash = ({onClick}: {onClick?: () => void}) => {
  const style: React.CSSProperties = onClick ? {cursor: "pointer"} : {};

  return (
    <svg width="24" height="24" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" onClick={onClick} style={style}>
      <g fill="none" fillRule="evenodd">
        <path d="M0 0h24v24H0z"/>
        <path d="M18.5 7v12c0 1.1-.9 2-2 2h-9c-1.1 0-2-.9-2-2V7h13zm-9 3h-1v8h1v-8zm3 0h-1v8h1v-8zm3 0h-1v8h1v-8zm-1-7 1 1h4v2h-15V4h4l1-1h5z" fill="#000" fillRule="nonzero"/>
      </g>
    </svg>
  );
};
