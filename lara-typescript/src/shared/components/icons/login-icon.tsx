import * as React from "react";

const kDefaultHeight = "1em";
const kDefaultWidth = "1em";

export interface ILoginProps {
  height?: string;
  width?: string;
}

export const Login = (props: ILoginProps) => {
  const height = props.height ? props.height : kDefaultHeight;
  const width = props.width ? props.width : kDefaultWidth;

  return(
    <svg
      width={width}
      height={height}
      viewBox="0 0 24 24"
    >
      <path d="M4 15h2v5h12V4H6v5H4V3a1 1 0 0 1 1-1h14a1 1 0 0 1 1 1v18a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-6zm6-4V8l5 4-5 4v-3H2v-2h8z"/>
    </svg>
  );
};
