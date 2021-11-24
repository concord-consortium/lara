import * as React from "react";
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
}

export const AccountOwner: React.FC<IAccountOwnerProps> = ({
    currentUser
  }: IAccountOwnerProps) => {

  const renderLoggedInUserContent = () => {
    const displayName = currentUser.first_name && currentUser.last_name
                          ? `${currentUser.first_name} ${currentUser.last_name}`
                          : currentUser.first_name
                            ? currentUser.first_name
                            : currentUser.email;
    return (
      <div className="account-owner-name">
        <AccountOwnerIcon />
        {displayName}
      </div>
    );
  };

  const accountOwnerContent = currentUser ? renderLoggedInUserContent() : null;
  return (
    <div className="account-owner" data-cy="account-owner">
      {accountOwnerContent}
    </div>
  );
};
