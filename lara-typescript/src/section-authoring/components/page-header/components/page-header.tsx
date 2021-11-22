import * as React from "react";
import { APIContainer } from "../../../containers/api-container";
import { Logo } from "./logo";
import { AccountOwner, IUser } from "./account-owner";

import "./page-header.scss";

export interface IPageHeaderProps {
  currentUser: IUser | null;
  logOutURL: string;
  host: string;
}

export const PageHeader: React.FC<IPageHeaderProps> = ({
    currentUser,
    logOutURL,
    host
  }: IPageHeaderProps) => {

  return (
    <APIContainer host={host}>
      <div className="authoring-header" data-cy="authoring-header">
        <div className="inner">
          <div className="header-left">
            <Logo />
            <div className="separator" />
          </div>
          <div className="header-center">
            <div className="title-container" />
          </div>
          <div className="header-right">
            <AccountOwner currentUser={currentUser} logOutURL={logOutURL} />
          </div>
        </div>
      </div>
    </APIContainer>
  );
};
