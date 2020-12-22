import { useDecorateContent, ITextDecorationInfo } from "../../interactive-api-client";
import { renderHTML } from "./render-html";
import { addEventListeners, removeEventListeners, IDecorateReactOptions } from "@concord-consortium/text-decorator";
import { useEffect, useState } from "react";
import { IEventListeners } from "../../plugin-api";

const kClassName = "text-decorate";

export const useGlossaryDecoration = (): [IDecorateReactOptions, string] => {
  const [options, setOptions] = useState<IDecorateReactOptions>({ words: [], replace: "" });
  const [listeners, setListeners] = useState<IEventListeners>();

  useDecorateContent((msg: ITextDecorationInfo) => {
    const msgOptions = {
      words: msg.words,
      replace: renderHTML(msg.replace) as string | React.ReactElement,
    };
    setOptions(msgOptions);
    setListeners(msg.eventListeners);
  });

  useEffect(() => {
    listeners && addEventListeners(kClassName, listeners);
    return () => listeners && removeEventListeners(kClassName, listeners);
  });

  return [options, kClassName];
};
