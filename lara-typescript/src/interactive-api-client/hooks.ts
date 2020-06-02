import { useEffect, useState } from "react";
import { IInitInteractive } from "./types";
import * as client from "./api";

type UpdateFunc<S> = (prevState: S | null) => S;
const handleUpdate = <S>(newStateOrUpdateFunc: S | UpdateFunc<S>, prevState: S | null) => {
  if (typeof newStateOrUpdateFunc === "function") {
    return (newStateOrUpdateFunc as UpdateFunc<S>)(prevState);
  } else {
    return newStateOrUpdateFunc;
  }
};

export const useInteractiveState = <InteractiveState>() => {
  const [ interactiveState, setInteractiveState ] = useState<InteractiveState | null>(
    client.getInteractiveState<InteractiveState>()
  );

  useEffect(() => {
    // Setup client event listeners. They will ensure that another instance of this hook (or anything else
    // using client directly) makes changes to interactive state, this hook will receive these changes.
    const handleStateUpdate = (newState: InteractiveState) => {
      setInteractiveState(newState);
    };
    client.addInteractiveStateListener<InteractiveState>(handleStateUpdate);
    return () => {
      client.removeInteractiveStateListener<InteractiveState>(handleStateUpdate);
    };
  }, []);

  const handleSetInteractiveState = (stateOrUpdateFunc: InteractiveState | UpdateFunc<InteractiveState>) => {
    // Use client-managed state, as it should be up to date. React-managed state might not be the most recent version.
    const newState = handleUpdate<InteractiveState>(stateOrUpdateFunc, client.getInteractiveState<InteractiveState>());
    setInteractiveState(newState);
    client.setInteractiveState<InteractiveState>(newState);
  };

  return { interactiveState, setInteractiveState: handleSetInteractiveState };
};

export const useAuthoredState = <AuthoredState>() => {
  const [ authoredState, setAuthoredState ] = useState<AuthoredState | null>(client.getAuthoredState<AuthoredState>());

  useEffect(() => {
    // Setup client event listeners. They will ensure that another instance of this hook (or anything else
    // using client directly) makes changes to authored state, this hook will receive these changes.
    const handleStateUpdate = (newState: AuthoredState) => {
      setAuthoredState(newState);
    };
    client.addAuthoredStateListener<AuthoredState>(handleStateUpdate);
    return () => {
      client.removeAuthoredStateListener<AuthoredState>(handleStateUpdate);
    };
  }, []);

  const handleSetAuthoredState = (stateOrUpdateFunc: AuthoredState | UpdateFunc<AuthoredState>) => {
    // Use client-managed state, as it should be up to date. React-managed state might not be the most recent version.
    const newState = handleUpdate<AuthoredState>(stateOrUpdateFunc, client.getAuthoredState<AuthoredState>());
    setAuthoredState(newState);
    client.setAuthoredState<AuthoredState>(newState);
  };

  return { authoredState, setAuthoredState: handleSetAuthoredState };
};

export const useGlobalInteractiveState = <GlobalInteractiveState>() => {
  const [ globalInteractiveState, setGlobalInteractiveState ] = useState<GlobalInteractiveState | null>(
    client.getGlobalInteractiveState<GlobalInteractiveState>()
  );

  useEffect(() => {
    // Setup client event listeners. They will ensure that another instance of this hook (or anything else
    // using client directly) makes changes to global interactive state, this hook will receive these changes.
    const handleStateUpdate = (newState: GlobalInteractiveState) => {
      setGlobalInteractiveState(newState);
    };
    client.addGlobalInteractiveStateListener<GlobalInteractiveState>(handleStateUpdate);
    return () => {
      client.removeGlobalInteractiveStateListener<GlobalInteractiveState>(handleStateUpdate);
    };
  }, []);

  // tslint:disable-next-line:max-line-length
  const handleSetGlobalInteractiveState = (stateOrUpdateFunc: GlobalInteractiveState | UpdateFunc<GlobalInteractiveState>) => {
    // Use client-managed state, as it should be up to date. React-managed state might not be the most recent version.
    const newState = handleUpdate<GlobalInteractiveState>(
      stateOrUpdateFunc, client.getGlobalInteractiveState<GlobalInteractiveState>()
    );
    setGlobalInteractiveState(newState);
    client.setGlobalInteractiveState<GlobalInteractiveState>(newState);
  };

  return { globalInteractiveState, setGlobalInteractiveState: handleSetGlobalInteractiveState };
};

// tslint:disable-next-line:max-line-length
export const useInitMessage = <InteractiveState = {}, AuthoredState = {}, DialogState = {}, GlobalInteractiveState = {}>() => {
  type InitMessage = IInitInteractive<InteractiveState, AuthoredState, DialogState, GlobalInteractiveState>;
  const [ initMessage, setInitMessage ] = useState<InitMessage | null>(null);

  useEffect(() => {
    // useEffect callback can't be async.
    (async () => {
      setInitMessage(await client.getInitInteractiveMessage());
    })();
  }, []);

  return initMessage;
};
