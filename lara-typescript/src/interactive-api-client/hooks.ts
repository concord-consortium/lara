import { useEffect, useState } from "react";
import { IInitInteractive } from "./types";
import * as client from "./api";

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

  const handleSetInteractiveState = (state: InteractiveState) => {
    setInteractiveState(state);
    client.setInteractiveState<InteractiveState>(state);
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

  const handleSetAuthoredState = (state: AuthoredState) => {
    setAuthoredState(state);
    client.setAuthoredState<AuthoredState>(state);
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

  const handleSetGlobalInteractiveState = (state: GlobalInteractiveState) => {
    setGlobalInteractiveState(state);
    client.setGlobalInteractiveState<GlobalInteractiveState>(state);
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
