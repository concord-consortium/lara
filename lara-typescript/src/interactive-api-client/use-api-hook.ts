import { useState, useEffect, useRef } from "react";
import { IHookOptions, InitInteractiveMode, INavigationOptions, IAuthInfo, IGetFirebaseJwtOptions } from "./types";
import { Client } from "./client";

// tslint:disable-next-line:max-line-length
export function useLaraInteractiveApi<InteractiveState = {}, AuthoredState = {}, GlobalInteractiveState = {}>(hookOptions: IHookOptions) {
  const client = useRef<Client>();
  const [ mode, setMode ] = useState<InitInteractiveMode>();
  const [ authoredState, setAuthoredState ] = useState<AuthoredState|null>(null);
  const [ interactiveState, setInteractiveState ] = useState<InteractiveState|null>(null);
  const [ globalInteractiveState, setGlobalInteractiveState ] = useState<GlobalInteractiveState|null>(null);

  useEffect(() => {
    client.current = new Client<InteractiveState, AuthoredState, GlobalInteractiveState>({
      startDisconnected: false,
      supportedFeatures: hookOptions.supportedFeatures,

      onInitInteractive: (initMessage) => {
        setAuthoredState(initMessage.authoredState);
        if ((initMessage.mode === "runtime") || (initMessage.mode === "report")) {
          setInteractiveState(initMessage.interactiveState);
        }
        if (initMessage.mode === "runtime") {
          setGlobalInteractiveState(initMessage.globalInteractiveState);
        }
        setMode(initMessage.mode);
      },

      onGetInteractiveState: () => interactiveState,

      onGlobalInteractiveStateUpdated: (state) => setGlobalInteractiveState(state),
    });

    // Cleanup function.
    return () => {
      if (client.current) {
        client.current.disconnect();
      }
    };
  }, []);

  const handleSetAuthoredState = (state: AuthoredState) => {
    setAuthoredState(state);
    if (client.current) {
      client.current.setAuthoredState(state);
    }
  };

  const handleSetInteractiveState = (state: InteractiveState) => {
    setInteractiveState(state);
    if (client.current) {
      client.current.setInteractiveState(state);
    }
  };

  const handleSetGlobalInteractiveState = (state: GlobalInteractiveState) => {
    setGlobalInteractiveState(state);
    if (client.current) {
      client.current.setGlobalInteractiveState(state);
    }
  };

  const handleSetHeight = (height: number | string) => {
    if (client.current) {
      client.current.setHeight(height);
    }
  };

  const handleSetHint = (hint: string) => {
    if (client.current) {
      client.current.setHint(hint);
    }
  };

  const handleSetAspectRatio = (aspectRatio: number) => {
    if (client.current) {
      const existingFeatures = hookOptions.supportedFeatures || {};
      const aspectRatioFeature = { aspectRatio };
      const supportedFeatures = {...existingFeatures, ...aspectRatioFeature};
      client.current.setSupportedFeatures(supportedFeatures);
    }
  };

  const handleSetNavigation = (navOptions: INavigationOptions) => {
    if (client.current) {
      client.current.setNavigation(navOptions);
    }
  };

  const handleGetAuthInfo = () => {
    return new Promise<IAuthInfo>((resolve, reject) => {
      if (client.current) {
        client.current.getAuthInfo().then(resolve).catch(reject);
      } else {
        reject("No client available!");
      }
    });
  };

  const handleGetFirebaseJWT = (jwtOptions: IGetFirebaseJwtOptions) => {
    return new Promise<string>((resolve, reject) => {
      if (client.current) {
        client.current.getFirebaseJWT(jwtOptions).then(resolve).catch(reject);
      } else {
        reject("No client available!");
      }
    });
  };

  return {
    mode,
    authoredState,
    interactiveState,
    globalInteractiveState,
    setAuthoredState: handleSetAuthoredState,
    setInteractiveState: handleSetInteractiveState,
    setGlobalInteractiveState: handleSetGlobalInteractiveState,
    setHeight: handleSetHeight,
    setAspectRatio: handleSetAspectRatio,
    setHint: handleSetHint,
    setNavigation: handleSetNavigation,
    getAuthInfo: handleGetAuthInfo,
    getFirebaseJWT: handleGetFirebaseJWT
  };
}
