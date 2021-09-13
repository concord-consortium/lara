import * as React from "react";

const kDefaultHight = "1em";
const kDefaultWidth = "1em";

export interface IHomeProps {
  fillColor?: string;
  height?: string;
  width?: string;
}

export const Home = (props: IHomeProps) => {
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
      viewBox="25 0 1613 2048"
      xmlns="http://www.w3.org/2000/svg">
      <path d="M1408 1120v480c0 17.333-6.333 32.333-19 45s-27.667 19-45 19H960v-384H704v384H320c-17.333 0-32.333-6.333-45-19s-19-27.667-19-45v-480c0-.667.167-1.667.5-3s.5-2.333.5-3l575-474 575 474c.667 1.333 1 3.333 1 6zm223-69l-62 74c-5.333 6-12.333 9.667-21 11h-3c-8.667 0-15.667-2.333-21-7L832 552l-692 577c-8 5.333-16 7.667-24 7-8.667-1.333-15.667-5-21-11l-62-74c-5.333-6.667-7.667-14.5-7-23.5s4.333-16.167 11-21.5l719-599c21.333-17.333 46.667-26 76-26s54.667 8.667 76 26l244 204V416c0-9.333 3-17 9-23s13.667-9 23-9h192c9.333 0 17 3 23 9s9 13.667 9 23v408l219 182c6.667 5.333 10.333 12.5 11 21.5s-1.667 16.833-7 23.5z"></path>
    </svg>
  );
};
