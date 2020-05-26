import * as React from "react";
import * as iframePhone from "iframe-phone";
import { useEffect, useRef, useState } from "react";

interface Props {
  src: string;
  width: string | number;
  height?: string | number;
  initialAuthoredState: object | null;
  initMsg: any;
  resetCount?: number;
  onAuthoredStateChange?: (authoredState: string | object) => void;
  aspectRatio: number;
  aspectRatioMethod: string;
  onSupportedFeaturesUpdate: (info: any) => void;
  onHeightChange: (height: number | string) => void;
  onSetIFrameRef: (iframeRef: HTMLIFrameElement | null) => void;
}

interface IFramePhoneParentEndpoint {
  addListener: (event: string, callback: (data: any) => void) => void;
  disconnect: () => void;
  post: (message: string, data: any) => void;
}

export const InteractiveIframe: React.FC<Props> = (props) => {
  const {
    src, width, height, initMsg, onAuthoredStateChange, resetCount,
    onSupportedFeaturesUpdate, onHeightChange, onSetIFrameRef,
    aspectRatio, aspectRatioMethod
  } = props;

  const iframe = useRef<HTMLIFrameElement|null>(null);
  onSetIFrameRef(iframe.current);

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
    phone.addListener("supportedFeatures", (info: any) => onSupportedFeaturesUpdate(info));
    phone.addListener("height", (newHeight: number | string) => onHeightChange(newHeight));
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

  return (
    <iframe
      ref={iframe}
      src={src}
      width={width}
      height={height}
      key={iframeId}
      frameBorder="no"
      scrolling="no"
      allowFullScreen={true}
      allow="geolocation *; microphone *; camera *"
      data-aspect_ratio={aspectRatio}
      data-aspect_ratio_method={aspectRatioMethod}
      data-iframe_mouseover="false"
      onLoad={handleIframeLoaded}
    />
  );
};
