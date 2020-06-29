import { useState, useEffect } from "react";

export interface UserCheckApiResponse {
  user: {
    id: number;
    email: string;
    is_admin: boolean;
    is_author: boolean;
  };
}

export interface User {
  id: number;
  email: string;
  isAdmin: boolean;
  isAuthor: boolean;
}

export const useCurrentUser = () => {
  const [user, setUser] = useState<User|undefined|null>(undefined);

  useEffect(() => {
    fetch("/api/v1/user_check", {credentials: "same-origin"})
      .then(result => result.json())
      .then((json: UserCheckApiResponse|null) => {
        const jsonUser = json?.user;
        if (jsonUser) {
          const {id, email, is_admin, is_author} = jsonUser;
          setUser({
            id,
            email,
            isAdmin: is_admin,
            isAuthor: is_author,
          });
        } else {
          setUser(null);
        }
      })
      .catch(() => setUser(null));
  }, []);

  return user;
};
