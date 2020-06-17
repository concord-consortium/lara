import * as React from "react";
import * as iframePhone from "iframe-phone";
import { useEffect, useRef, useState } from "react";

interface Props {
  src: string;
  width: string | number;
  initialAuthoredState: object | null;
  initMsg: any;
  resetCount?: number;
  onAuthoredStateChange?: (authoredState: string | object) => void;
  authoredAspectRatio: number;
  authoredAspectRatioMethod: string;
}

interface IFramePhoneParentEndpoint {
  addListener: (event: string, callback: (data: any) => void) => void;
  disconnect: () => void;
  post: (message: string, data: any) => void;
}

export const InteractiveIframe: React.FC<Props> = (props) => {
  const {
    src, width, initMsg, onAuthoredStateChange, resetCount,
    authoredAspectRatio, authoredAspectRatioMethod
  } = props;

  const iframe = useRef<HTMLIFrameElement|null>(null);

  // FIXME: The default height here should be based on the aspect ratio setting
  // and the width of the iframe. That computation at runtime is currently handled
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
  // So probably the best option is to abstract that code.
  const [height, setHeight] = useState<number|string|null>(null);
  const [aspectRatio, setAspectRatio] = useState<number>(authoredAspectRatio);

  const handleHeightChange = (newHeight: number | string) => {
    setHeight(newHeight);
  };

  const handleSupportedFeatures = (info: any) => {
    if (info.features.aspectRatio &&
        authoredAspectRatioMethod === "DEFAULT") {
      setAspectRatio(parseInt(info.features.aspectRatio));
    }
  };

  const [iframeId, setIFrameId] = useState<number>(0);
  let phone: IFramePhoneParentEndpoint;

  const connect = () => {
    phone = new iframePhone.ParentEndpoint(iframe.current!, () => {
      phone.post("initInteractive", initMsg);
    });
    phone.addListener("authoredState", (authoredState: any) => {
      if (onAuthoredStateChange) {
        onAuthoredStateChange(authoredState);
      }
    });
    phone.addListener("supportedFeatures", (info: any) => handleSupportedFeatures(info));
    phone.addListener("height", (newHeight: number | string) => handleHeightChange(newHeight));
  };
  const disconnect = () => {
    if (phone) {
      phone.disconnect();
    }
  };

  const handleIframeLoaded = () => {
    connect();
  };

  useEffect(() => {
    return () => {
      disconnect();
    };
  }, []);

  useEffect(() => {
    if (iframe.current) {
      disconnect();
      setIFrameId(iframeId + 1);
    }
  }, [src, resetCount]);

  let computedHeight = 300;
  if(height !== null) {
    computedHeight = Number(height);
  } else if(iframe.current && aspectRatio) {
    computedHeight = Math.round(iframe.current.offsetWidth / aspectRatio);
  }

  return (
    <iframe
      ref={iframe}
      src={src}
      width={width}
      height={computedHeight}
      key={iframeId}
      frameBorder="no"
      scrolling="no"
      allowFullScreen={true}
      allow="geolocation *; microphone *; camera *"
      data-iframe_mouseover="false"
      onLoad={handleIframeLoaded}
    />
  );
};
