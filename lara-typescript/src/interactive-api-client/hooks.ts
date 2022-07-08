import { useEffect, useState } from "react";
import ResizeObserver from "resize-observer-polyfill";

import { ICustomMessageHandler, ICustomMessagesHandledMap, IInitInteractive, ITextDecorationHandler,
  IReportItemHandlerMetadata, IGetReportItemAnswerHandler } from "./types";
import * as client from "./api";

type UpdateFunc<S> = (prevState: S | null) => S;
const handleUpdate = <S>(newStateOrUpdateFunc: S | null | UpdateFunc<S>, prevState: S | null) => {
  if (typeof newStateOrUpdateFunc === "function") {
    return (newStateOrUpdateFunc as UpdateFunc<S>)(prevState);
  } else {
    return newStateOrUpdateFunc;
  }
};

export const useInteractiveState = <InteractiveState>() => {
  const [ interactiveState, setInteractiveState ] = useState<InteractiveState | null>(null);

  useEffect(() => {
    setInteractiveState(client.getInteractiveState<InteractiveState>());
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

  const handleSetInteractiveState = (stateOrUpdateFunc: InteractiveState | UpdateFunc<InteractiveState> | null) => {
    // Use client-managed state, as it should be up to date. React-managed state might not be the most recent version.
    const newState = handleUpdate<InteractiveState>(stateOrUpdateFunc, client.getInteractiveState<InteractiveState>());
    setInteractiveState(newState);
    client.setInteractiveState<InteractiveState>(newState);
  };

  return { interactiveState, setInteractiveState: handleSetInteractiveState };
};

export const useAuthoredState = <AuthoredState>() => {
  const [ authoredState, setAuthoredState ] = useState<AuthoredState | null>(null);

  useEffect(() => {
    // Note that we need to update authoredState exactly in this moment, right before setting up event listeners.
    // It can't be done above using initial useState value. There's a little delay between initial render and calling
    // useEffect. If client's authoredState gets updated before the listener is added, this hook will have outdated
    // value. It's not only a theoretical issue, it was actually happening in Safari:
    // https://www.pivotaltracker.com/story/show/174154314
    // initInteractive message that includes authoredAuthored message was received between initial render and calling
    // client.addAuthoredStateListener, so the state update was lost.
    setAuthoredState(client.getAuthoredState<AuthoredState>());
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

  const handleSetAuthoredState = (stateOrUpdateFunc: AuthoredState | UpdateFunc<AuthoredState> | null) => {
    // Use client-managed state, as it should be up to date. React-managed state might not be the most recent version.
    const newState = handleUpdate<AuthoredState>(stateOrUpdateFunc, client.getAuthoredState<AuthoredState>());
    setAuthoredState(newState);
    client.setAuthoredState<AuthoredState>(newState);
  };

  return { authoredState, setAuthoredState: handleSetAuthoredState };
};

export const useGlobalInteractiveState = <GlobalInteractiveState>() => {
  const [ globalInteractiveState, setGlobalInteractiveState ] = useState<GlobalInteractiveState | null>(null);

  useEffect(() => {
    setGlobalInteractiveState(client.getGlobalInteractiveState<GlobalInteractiveState>());
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
  const handleSetGlobalInteractiveState = (stateOrUpdateFunc: GlobalInteractiveState | UpdateFunc<GlobalInteractiveState> | null ) => {
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
export const useInitMessage = <InteractiveState = {}, AuthoredState = {}, GlobalInteractiveState = {}>() => {
  type InitMessage = IInitInteractive<InteractiveState, AuthoredState, GlobalInteractiveState>;
  const [ initMessage, setInitMessage ] = useState<InitMessage | null>(null);

  useEffect(() => {
    // useEffect callback can't be async.
    (async () => {
      const initMsg =
        await client.getInitInteractiveMessage<InteractiveState, AuthoredState, GlobalInteractiveState>();
      setInitMessage(initMsg);
    })();
  }, []);

  return initMessage;
};

export const useCustomMessages = (callback: ICustomMessageHandler, handles?: ICustomMessagesHandledMap) => {
  useEffect(() => {
    client.addCustomMessageListener(callback, handles);

    return () => { client.removeCustomMessageListener() };
  }, []);
};

export const useDecorateContent = (callback: ITextDecorationHandler) => {
  useEffect(() => {
    client.addDecorateContentListener(callback);
    return () => client.removeDecorateContentListener();
  }, []);
};

export const useAutoSetHeight = () => {
  const initMessage = useInitMessage();

  useEffect(() => {
    if (initMessage) {
      const body = document.body;
      const html = document.documentElement;
      const updateHeight = () => {
        const height = Math.max(
          body.scrollHeight,
          body.offsetHeight,
          html.clientHeight,
          html.scrollHeight,
          html.offsetHeight
        );
        client.setHeight(height);
      };
      const observer = new ResizeObserver(() => updateHeight());
      if (body) {
        observer.observe(body);
      }
      return () => observer.disconnect();
    }
  }, [initMessage]);
};


export interface IUseReportItemOptions<InteractiveState, AuthoredState> {
  metadata: IReportItemHandlerMetadata,
  handler: IGetReportItemAnswerHandler<InteractiveState, AuthoredState>
}

export const useReportItem = <InteractiveState, AuthoredState>({ metadata, handler }: IUseReportItemOptions<InteractiveState, AuthoredState>) => {
  useEffect(() => {
    client.addGetReportItemAnswerListener(handler);

    client.notifyReportItemClientReady(metadata);

    return () => client.removeGetReportItemAnswerListener();
  }, []);
};
