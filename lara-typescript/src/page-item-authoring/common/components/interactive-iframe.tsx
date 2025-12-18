import * as React from "react";
import * as iframePhone from "iframe-phone";
import { useEffect, useRef, useState } from "react";

import * as LaraInteractiveApi from "../../../interactive-api-client";
import { IInteractiveListResponseItem, IInitInteractive } from "../../../interactive-api-client";
import { AuthoringApiUrls } from "../types";

type IGetFirebaseJwtRequestOptionalRequestId = LaraInteractiveApi.IGetFirebaseJwtRequest;
type IGetFirebaseJwtResponseOptionalRequestId = LaraInteractiveApi.IGetFirebaseJwtResponse;

interface Props {
  src: string;
  width: string | number;
  initialAuthoredState: object | null;
  initMsg: IInitInteractive;
  resetCount?: number;
  onAuthoredStateChange?: (authoredState: string | object) => void;
  onDirtyStateChange?: (isDirty: boolean) => void;
  onLinkedInteractivesChange?: (linkedInteractives: LaraInteractiveApi.ISetLinkedInteractives) => void;
  onSupportedFeaturesUpdate?: (info: any) => void;
  authoredAspectRatio: number;
  authoredAspectRatioMethod: string;
  authoringApiUrls?: AuthoringApiUrls;
}

export interface IframePhone {
  post: (type: string, data?: any) => void;
  addListener: (type: string, handler: (data: any) => void) => void;
  initialize: () => void;
  disconnect: () => void;
}

export const InteractiveIframe: React.FC<Props> = (props) => {
  const {
    src, width, initMsg, onAuthoredStateChange, onDirtyStateChange, onLinkedInteractivesChange,
    resetCount, onSupportedFeaturesUpdate, authoredAspectRatio, authoredAspectRatioMethod,
    authoringApiUrls
  } = props;

  const iframeRef = useRef<HTMLIFrameElement|null>(null);
  const phoneRef = useRef<IframePhone>();

  // FIXME: The interactive sizing computation at runtime is currently handled
  // by the setSize method in interactives-sizing.js
  // That code can't be used here, because the jQuery changes to the iframe
  // conflict with the React management of the iframe element.
  // We could:
  // - duplicate the sizing code here
  // - abstract it so it can be shared by both the runtime and authoring.
  // - move the runtime iframe rendering into React, so both authoring and
  //   runtime use the interactiveIframe component
  // The last option is the best for maintainability, but it will slow down the
  // page load since the iframes won't start loading until the javascript is loaded
  // So probably the best option is to abstract that sizing code so it can be
  // used by both jQuery and React
  const [height, setHeight] = useState<number|string|null>(null);
  const [aspectRatio, setAspectRatio] = useState<number>(authoredAspectRatio);

  const handleHeightChange = (newHeight: number | string) => {
    setHeight(newHeight);
  };

  const handleSupportedFeatures = (info: any) => {
    if (info.features.aspectRatio &&
        authoredAspectRatioMethod === "DEFAULT") {
      setAspectRatio(parseInt(info.features.aspectRatio, 10));
    }
    if (onSupportedFeaturesUpdate) {
      onSupportedFeaturesUpdate(info);
    }
  };

  const handleGetInteractiveList = (request: LaraInteractiveApi.IGetInteractiveListRequest, url: string) => {
    const {requestId, scope, supportsSnapshots} = request;
    const urlWithParams = `${url}?scope=${scope}&amp;supportsSnapshots=${supportsSnapshots}`;

    return fetch(urlWithParams, {
      method: "GET",
      headers: {
        "Content-type": "application/json"
      }
    })
    .then(response => response.json())
    .then((data: {interactives: IInteractiveListResponseItem[]}) => {
      phoneRef.current?.post("interactiveList", {requestId, interactives: data.interactives});
    })
    .catch((error) => {
      phoneRef.current?.post("interactiveList", {requestId, response_type: "ERROR", message: error});
    });
  };

  const handleGetFirebaseJwt = (request?: IGetFirebaseJwtRequestOptionalRequestId) => {
    const requestId = request ? request.requestId : undefined;
    const opts: any = request || {};
    if (opts.requestId) {
      delete opts.requestId;
    }

    const createResponse = (baseResponse: IGetFirebaseJwtResponseOptionalRequestId) => {
      if (requestId) {
        baseResponse.requestId = requestId;
      }
      return baseResponse;
    };

    return fetch("/api/v1/get_firebase_jwt", {
      method: "POST",
      headers: {
        "Content-type": "application/json"
      },
      body: JSON.stringify(opts)
    })
    .then(response => response.json())
    .then((data: {token: string}) => {
      phoneRef.current?.post("firebaseJWT", createResponse({requestId: requestId!, token: data.token}));
    })
    .catch((error) => {
      phoneRef.current?.post(
        "firebaseJWT", createResponse({requestId: requestId!, response_type: "ERROR", message: error}
      ));
    });
  };

  useEffect(() => {
    const initInteractive = () => {
      const phone = phoneRef.current;
      if (!phone) {
        return;
      }
      phone.addListener("authoredState", (authoredState: any) => {
        if (onAuthoredStateChange) {
          onAuthoredStateChange(authoredState);
        }
      });
      phone.addListener("supportedFeatures", (info: any) => handleSupportedFeatures(info));
      phone.addListener("height", (newHeight: number | string) => handleHeightChange(newHeight));

      const getInteractiveListUrl = authoringApiUrls?.get_interactive_list;
      if (getInteractiveListUrl) {
        phone.addListener("getInteractiveList",
          (request: LaraInteractiveApi.IGetInteractiveListRequest) => {
            handleGetInteractiveList(request, getInteractiveListUrl);
          }
        );
      }

      phone.addListener("setLinkedInteractives", (request: LaraInteractiveApi.ISetLinkedInteractives) => {
        onLinkedInteractivesChange?.(request);
      });

      phone.addListener("setDirtyState", (request: LaraInteractiveApi.ISetDirtyStateRequest) => {
        onDirtyStateChange?.(request.isDirty);
      });

      phone.addListener("getFirebaseJWT", (request?: IGetFirebaseJwtRequestOptionalRequestId) => {
        return handleGetFirebaseJwt(request);
      });
      try {
        phone.post("initInteractive", initMsg);
      }
      catch (e) {
        // tslint:disable-next-line
        console.log("Error", e);
      }
    };

    if (iframeRef.current) {
      // Reload the iframe.
      iframeRef.current.src = src;
      // Re-init interactive, this time using a new mode (report or runtime).
      phoneRef.current = new iframePhone.ParentEndpoint(iframeRef.current, initInteractive) as unknown as IframePhone;
    }

    // Cleanup.
    return () => {
      if (phoneRef.current) {
        phoneRef.current.disconnect();
      }
    };
    // Re-running the effect reloads the iframe.
    // The _only_ time that's ever appropriate is when the url has changed.
  }, [resetCount, src]);  // eslint-disable-line react-hooks/exhaustive-deps

  let computedHeight = 300;
  if (height !== null) {
    computedHeight = Number(height);
  } else if (iframeRef.current && aspectRatio) {
    computedHeight = Math.round(iframeRef.current.offsetWidth / aspectRatio);
  }

  return (
    <iframe
      data-reset-count={resetCount}
      ref={iframeRef}
      src={src}
      width={width}
      height={computedHeight}
      key={resetCount}
      frameBorder="no"
      scrolling="no"
      allowFullScreen={true}
      allow="geolocation *; microphone *; camera *"
      data-iframe_mouseover="false"
    />
  );
};
