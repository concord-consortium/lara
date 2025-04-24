import * as React from "react";
import { accessibilityClick } from "../../../util/accessibility-helper";
import { CCLogo } from "./cc-logo";

import "./logo.scss";

interface ILogoProps {
  logoPath?: string;
}

export const Logo: React.FC<ILogoProps> = ({
    logoPath
  }: ILogoProps) => {
  const logo = logoPath
                 ? <img data-testid="logo-img" className="logo-img" src={logoPath} alt="Authoring Home"/>
                 : <CCLogo/>;

  const handleClick = (e: React.MouseEvent<HTMLElement> | React.KeyboardEvent<HTMLElement>) => {
    if (accessibilityClick(e)) {
      window.location.href = "/";
    }
  };

  return (
    <div className="project-logo" onClick={handleClick} onKeyDown={handleClick} tabIndex={0}>
      {logo}
      <span className="project-logo-label">Authoring</span>
    </div>
  );
};
