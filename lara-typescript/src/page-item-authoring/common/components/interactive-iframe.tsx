import * as React from "react";
import { useEffect, useRef, useState } from "react";

interface Props {
  src: string;
  width: string | number;
  height: string | number;
  initialAuthoredState: object | null;
  initMsg: any;
  resetCount: number;
  onAuthoredStateChange: (authoredState: string | object) => void;
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
    onSupportedFeaturesUpdate, onHeightChange, onSetIFrameRef
  } = props;

  const iframe = useRef<HTMLIFrameElement|null>(null);
  onSetIFrameRef(iframe.current);

  const [iframeId, setIFrameId] = useState<number>(0);
  let phone: IFramePhoneParentEndpoint;

  const connect = () => {
    console.log("connect");
    phone = new (window as any).iframePhone.ParentEndpoint(iframe.current, () => {
      phone.post("initInteractive", initMsg);
    });
    phone.addListener("authoredState", (authoredState: any) => onAuthoredStateChange(authoredState));
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
      console.log("useEffect disconnect");
      disconnect();
    };
  }, []);

  useEffect(() => {
    console.log("src/resetCount useEffect");
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
      allowFullScreen={true}
      onLoad={handleIframeLoaded}
    />
  );
};
