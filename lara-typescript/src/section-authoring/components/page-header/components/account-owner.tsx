import * as React from "react";
import { useState } from "react";
import { usePageAPI } from "../../../hooks/use-api-provider";
import { LoginIcon } from "../../../../shared/components/icons/login-icon";
import { HelpIcon } from "../../../../shared/components/icons/help-icon";
import { AccountOwnerIcon } from "../../../../shared/components/icons/account-owner-icon";

import "./account-owner.scss";

export interface IUser {
  api_key: string;
  can_export: boolean;
  created_at: string;
  email: string;
  first_name: string;
  id: number;
  is_admin: boolean;
  is_author: boolean;
  last_name: string;
  updated_at: string;
}

export interface IAccountOwnerProps {
  currentUser: any;
  logOutURL: string;
}

export const AccountOwner: React.FC<IAccountOwnerProps> = ({
    currentUser,
    logOutURL
  }: IAccountOwnerProps) => {
  const { getPortals } = usePageAPI();
  const [showLogInOptions, setShowLogInOptions] = useState(false);

  const handleLogInClick = () => {
    setShowLogInOptions(!showLogInOptions);
  };

  const renderPortalList = () => {
    const portals = getPortals.data?.portals;
    const portalList = portals?.map((p, index) => {
       return <li key={`portal-${p.name}-${index}`}><a href={p.path}>Log in via {p.name}</a></li>;
    });
    return portalList;
  };

  const renderAnonymousUserContent = () => {
    return (
      <>
        <div className="account-owner-name">
          <div onClick={handleLogInClick}><LoginIcon height="20" width="20" />Log In</div>
        </div>
        <div className={`account-log-in-options ${showLogInOptions ? "show" : ""}`}>
          <ul>
            {renderPortalList()}
            <li>
              <a
                href="https://docs.google.com/document/d/1d-06qDtpxi-l9eOc1wfYGZzY93Pww32IfZxBJaBXlWM"
                target="_blank"
                rel="noopener"
              >
                <HelpIcon height="20" width="20" />
                Help
              </a>
            </li>
          </ul>
        </div>
      </>
    );
  };

  const renderLoggedInUserContent = () => {
    const displayName = currentUser.first_name && currentUser.last_name
                          ? `${currentUser.first_name} ${currentUser.last_name}`
                          : currentUser.first_name
                            ? currentUser.first_name
                            : currentUser.email;
    return (
      <div className="account-owner-name">
        <AccountOwnerIcon />
        {displayName} | <a href={logOutURL} data-method="delete">Log Out</a>
      </div>
    );
  };

  const accountOwnerContent = currentUser ? renderLoggedInUserContent() : renderAnonymousUserContent();
  return (
    <div className={`account-owner ${showLogInOptions ? "active" : ""}`} data-cy="account-owner">
      {accountOwnerContent}
    </div>
  );
};
