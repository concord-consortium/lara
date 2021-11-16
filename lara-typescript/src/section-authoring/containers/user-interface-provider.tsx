import * as React from "react";
import { useImmer } from "use-immer";
import { PageId } from "../api/api-types";

interface IUserInterface {
  currentPageId: PageId | null;
  movingItemId: string | false;
  movingSectionId: string | false;
  editingItemId: string | false;
}

const defaultUI: IUserInterface = {
  currentPageId: null,
  movingItemId: false,
  movingSectionId: false,
  editingItemId: false
};

interface IUIActions {
  setMovingItemId: (id: false|string) => void;
  setMovingSectionId: (id: false|string) => void;
  setEditingItemId: (id: false|string) => void;
  setCurrentPageId: (id: false|string) => void;
}

interface IUIContext {
  userInterface: IUserInterface;
  actions: IUIActions;
}

export const defaultUIContext: IUIContext = {
  userInterface: defaultUI,
  actions: {
    // tslint:disable-next-line
    setMovingItemId: (id) => console.log(id),
    // tslint:disable-next-line
    setMovingSectionId: (id) => console.log(id),
    // tslint:disable-next-line
    setEditingItemId: (id) => console.log(id),
    // tslint:disable-next-line
    setCurrentPageId: (id) => console.log(id)
  }
};

const UserInterfaceContext = React.createContext<IUIContext>(defaultUIContext);

// 1: We define a context to be consumed from by sub-components.
// 2: We provide a hook for the wrapping component in api-container component
// 3: This api-container component provides UI features via context.
// Sample from consuming component:
// `const { userInterface, actions }  = React.useContext(UserInterfaceContext);`

const UserInterfaceProvider: React.FC = ({children}) => {
  const [userInterface, setUserInterface] = useImmer<IUserInterface>(defaultUI);
  const setMovingItemId = (id: string| false) => {
    setUserInterface( (draft) => { draft.movingItemId = id; });
  };

  const setMovingSectionId = (id: string| false) => {
    setUserInterface( (draft) => { draft.movingSectionId = id; });
  };

  const setEditingItemId = (id: string| false) => {
    setUserInterface( (draft) => { draft.editingItemId = id; });
  };

  const setCurrentPageId = (id: string) => {
    const url = window.location.toString();
    const nextUrl = url.replace(/\/pages\/\d+\//, `/pages/${id}/`);
    const title = `edit page ${id}`;
    const data = {title};
    window.history.pushState(data, `edit page ${id}`, nextUrl);
    setUserInterface( (draft) => {draft.currentPageId = id; });
  };

  const actions = { setMovingItemId, setMovingSectionId, setEditingItemId, setCurrentPageId};
  return (
    <UserInterfaceContext.Provider value={{actions, userInterface}}>
      {children}
    </UserInterfaceContext.Provider>
  );
};

export { UserInterfaceContext, UserInterfaceProvider };
