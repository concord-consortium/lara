import * as React from "react";

const kDefaultHeight = "32px";
const kDefaultWidth = "32px";

export interface IAccountOwnerProps {
  height?: string;
  width?: string;
}

export const AccountOwnerIcon = (props: IAccountOwnerProps) => {
  const height = props.height ? props.height : kDefaultHeight;
  const width = props.width ? props.width : kDefaultWidth;

  return(
    <svg
      width={width}
      height={height}
      viewBox="0 0 32 32"
    >
      <g fill-rule="evenodd">
        <path fill="#fff" fill-rule="nonzero" d="M16 2.667C8.64 2.667 2.667 8.64 2.667 16S8.64 29.333 16 29.333 29.333 23.36 29.333 16 23.36 2.667 16 2.667z"/>
        <path fill-rule="nonzero" d="M16 25.6c-3.333 0-6.28-1.707-8-4.293.04-2.654 5.333-4.107 8-4.107 2.653 0 7.96 1.453 8 4.107-1.72 2.586-4.667 4.293-8 4.293zM16 6.667c2.213 0 4 1.786 4 4 0 2.213-1.787 4-4 4s-4-1.787-4-4c0-2.214 1.787-4 4-4z"/>
      </g>
    </svg>
  );
};
