import * as React from "react";

const kDefaultHeight = "1em";
const kDefaultWidth = "1em";

export interface IHelpProps {
  height?: string;
  width?: string;
}

export const Help = (props: IHelpProps) => {
  const height = props.height ? props.height : kDefaultHeight;
  const width = props.width ? props.width : kDefaultWidth;

  return(
    <svg
      width={width}
      height={height}
    >
      <path
        d="M10 1.667C5.4 1.667 1.667 5.4 1.667 10S5.4 18.333 10 18.333 18.333 14.6 18.333 10 14.6 1.667 10 1.667zm.833 14.166H9.167v-1.666h1.666v1.666zm1.725-6.458l-.75.767c-.6.608-.975 1.108-.975 2.358H9.167v-.417c0-.916.375-1.75.975-2.358l1.033-1.05c.308-.3.492-.717.492-1.175 0-.917-.75-1.667-1.667-1.667s-1.667.75-1.667 1.667H6.667c0-1.842 1.491-3.333 3.333-3.333s3.333 1.491 3.333 3.333c0 .733-.3 1.4-.775 1.875z"/>
    </svg>
  );
};
