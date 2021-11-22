import * as React from "react";
import {CCLogo} from "./cc-logo";

import "./logo.scss";

interface ILogoProps {
  logoPath?: string;
}

export const Logo: React.FC<ILogoProps> = ({
    logoPath
  }: ILogoProps) => {
  const logo = logoPath
                 ? <img data-cy="logo-img" className="logo-img" src={logoPath} alt="Authoring Home"/>
                 : <CCLogo/>;
  return (
    <div className="project-logo">
      {logo}
    </div>
  );
};
