import * as React from "react";

const kDefaultHeight = "1em";
const kDefaultWidth = "1em";

export interface INextProps {
  height?: string;
  width?: string;
}

export const Move = (props: INextProps) => {
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
      viewBox="0 0 369 369"
      xmlns="http://www.w3.org/2000/svg">
      <path d="M184.972,0C82.821,0,0,82.818,0,184.978c0,102.147,82.821,184.971,184.972,184.971 c102.16,0,184.978-82.824,184.978-184.971C369.949,82.812,287.138,0,184.972,0z M318.975,176.112l9.428,9.413l-9.428,9.422 c0,0-0.012,0.006-0.012,0.012l-31.093,31.099c-2.606,2.606-6.028,3.915-9.428,3.915c-3.423,0-6.821-1.309-9.428-3.915 c-5.206-5.206-5.206-13.643,0-18.843l8.347-8.347h-78.494v38.743c0,1.886-0.408,3.687-1.117,5.302v34.449l10.568-10.568 c5.213-5.212,13.655-5.212,18.855,0c5.212,5.2,5.212,13.644,0,18.85l-33.314,33.32l-0.024,0.012l-9.409,9.422l-9.416-9.422 l-0.018-0.012l-31.099-31.104c-5.209-5.212-5.209-13.649,0-18.85c5.212-5.206,13.643-5.206,18.852,0l8.344,8.353v-78.5h-38.74 c-1.885,0-3.681-0.402-5.305-1.117H92.597l10.571,10.574c5.212,5.213,5.212,13.643,0,18.844c-2.609,2.611-6.02,3.914-9.427,3.914 s-6.818-1.303-9.422-3.914l-33.32-33.314c-0.012-0.013-0.018-0.013-0.018-0.013l-9.413-9.421l9.413-9.416 c0,0,0.006-0.006,0.018-0.018l31.102-31.102c5.209-5.209,13.646-5.209,18.846,0c5.215,5.215,5.215,13.646,0,18.853l-8.344,8.347 h78.498v-38.746c0-1.889,0.405-3.684,1.114-5.299V92.579l-10.578,10.568c-2.6,2.609-6.014,3.912-9.427,3.912 c-3.411,0-6.819-1.303-9.419-3.912c-5.209-5.209-5.209-13.643,0-18.846l33.321-33.321c0,0,0.012-0.006,0.018-0.018l9.415-9.416 l9.419,9.416c0.006,0.012,0.012,0.018,0.012,0.018l31.105,31.102c5.206,5.206,5.206,13.643,0,18.846 c-5.213,5.215-13.644,5.215-18.85,0l-8.341-8.344v78.498h38.743c1.886,0,3.688,0.405,5.309,1.111h34.449l-10.574-10.569 c-5.212-5.209-5.212-13.651,0-18.854c5.212-5.206,13.643-5.206,18.849,0l33.314,33.323 C318.963,176.106,318.975,176.112,318.975,176.112z" />
    </svg>
  );
};