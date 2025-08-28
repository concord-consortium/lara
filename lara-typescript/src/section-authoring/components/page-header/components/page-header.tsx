import * as React from "react";
import classNames from "classnames";
import { APIContainer } from "../../../containers/api-container";
import { Logo } from "./logo";
import { AccountOwner, IUser } from "./account-owner";
import { PageHeaderMenu, IHeaderMenuLink } from "./page-header-menu";
import { renderHTML } from "../../../../shared/render-html";

import "./page-header.scss";

export interface IPageHeaderProps {
  currentUser: IUser | null;
  logOutURL: string;
  host: string;
  resourceName: string;
  userLinks: IHeaderMenuLink[];
}

export const PageHeader: React.FC<IPageHeaderProps> = ({
    currentUser,
    logOutURL,
    host,
    resourceName,
    userLinks
  }: IPageHeaderProps) => {

  const isEmptyResourceName = (resourceName ?? "").trim().length === 0;

  const handleTitleClick = () => {
    if (isEmptyResourceName) {
      return;
    }
    const activityPath = window.location.pathname.split("/pages")[0];
    window.location.href = activityPath + "/edit";
  };

  return (
    <APIContainer host={host}>
      <div className="authoring-header" data-testid="authoring-header">
        <div className="inner">
          <div className="header-left">
            <Logo />
            <div className="separator" />
          </div>
          <div className="header-center">
            <div className={classNames("title-container", { empty: isEmptyResourceName })} onClick={handleTitleClick}>
              <div className="activity-title" data-testid="activity-title">
                {renderHTML(resourceName)}
              </div>
            </div>
          </div>
          <div className="header-right">
            <AccountOwner currentUser={currentUser} />
            <PageHeaderMenu logOutURL={logOutURL} userLinks={userLinks} />
          </div>
        </div>
      </div>
    </APIContainer>
  );
};
