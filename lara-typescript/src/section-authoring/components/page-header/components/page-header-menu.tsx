import * as React from "react";
import { useEffect, useRef } from "react";
import { useState } from "react";
import { usePageAPI } from "../../../hooks/use-api-provider";
import { LoginIcon } from "../../../../shared/components/icons/login-icon";
import { HelpIcon } from "../../../../shared/components/icons/help-icon";
import { MenuIcon } from "../../../../shared/components/icons/menu-icon";
import { MenuCloseIcon } from "../../../../shared/components/icons/menu-close-icon";

import "./page-header-menu.scss";

export interface IHeaderMenuLink {
  text: string;
  path: string;
}

export interface IAccountOwnerProps {
  logOutURL: string;
  userLinks: IHeaderMenuLink[];
}

export const PageHeaderMenu: React.FC<IAccountOwnerProps> = ({
    logOutURL,
    userLinks
  }: IAccountOwnerProps) => {
  const { getPortals } = usePageAPI();
  const menuRef = useRef<HTMLDivElement|null>(null);
  const [showHeaderMenu, setShowHeaderMenu] = useState(false);

  useEffect(() => {
    document.addEventListener("mousedown", handleClick, false);
  }, []);

  const handleLogInClick = () => {
    setShowHeaderMenu(!showHeaderMenu);
  };

  const handleMenuClick = () => {
    setShowHeaderMenu(!showHeaderMenu);
  };

  const handleClick = (e: MouseEvent) => {
    if (menuRef.current && e.target && !menuRef.current.contains(e.target as Node)) {
      setShowHeaderMenu(false);
    }
  };

  const renderPortalList = () => {
    const portals = getPortals.data?.portals;
    const portalList = portals?.map((p, index) => {
       return <li key={`portal-${p.name}-${index}`}><a href={p.path}>Log in via {p.name}</a></li>;
    });
    return portalList;
  };

  const renderMenuLinks = () => {
    const linksList = userLinks.map((l, index) => {
      return <li key={`link-${l.path}-${index}`}><a href={l.path}>{l.text}</a></li>;
    });
    return linksList;
  };

  const renderAnonymousUserLinks = () => {
    return (
      <>
        <div className="login-link" onClick={handleLogInClick}>
          <LoginIcon height="20" width="20" />
          Log In
        </div>
        <div ref={menuRef} className={`header-menu-links ${showHeaderMenu ? "show" : ""}`}>
          <ul>
            {renderPortalList()}
            <li className="divider">
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

  const renderLoggedInUserLinks = () => {
    return (
      <>
        {showHeaderMenu
          ? <MenuCloseIcon data-testid="menu-close-icon" />
          : <MenuIcon data-testid="menu-icon" />
        }
        <div ref={menuRef} className={`header-menu-links ${showHeaderMenu ? "show" : ""}`}>
          <ul>
            {renderMenuLinks()}
            <li className="divider">
              <a
                href="https://docs.google.com/document/d/1d-06qDtpxi-l9eOc1wfYGZzY93Pww32IfZxBJaBXlWM"
                target="_blank"
                rel="noopener"
                data-testid="help-link"
              >
                <HelpIcon height="20" width="20" />
                Help
              </a>
            </li>
            <li>
              <a href={logOutURL} data-method="delete" data-testid="logout-link">
                <LoginIcon height="20" width="20" />
                Log Out
              </a>
            </li>
          </ul>
        </div>
      </>
    );
  };

  const menuLinks = logOutURL !== "" ? renderLoggedInUserLinks() : renderAnonymousUserLinks();
  return (
    <div className={`header-menu ${showHeaderMenu ? "active" : ""}`} onClick={handleMenuClick} data-cy="header-menu">
      {menuLinks}
    </div>
  );
};
