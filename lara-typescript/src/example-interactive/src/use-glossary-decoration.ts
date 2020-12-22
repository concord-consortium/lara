import { useDecorateContent, postDecoratedContentEvent } from "../../interactive-api-client";
import { renderHTML } from "./render-html";
import { addEventListeners, removeEventListeners, IDecorateReactOptions } from "@concord-consortium/text-decorator";
import { useEffect, useState } from "react";

const kClassName = "text-decorate";

export const useGlossaryDecoration = (): [IDecorateReactOptions, string] => {
  const [options, setOptions] = useState<IDecorateReactOptions>({ words: [], replace: "" });

  useDecorateContent((msg: any) => {
    const msgOptions = {
      words: msg.words,
      replace: renderHTML(msg.replace) as string | React.ReactElement,
    };
    setOptions(msgOptions);
  });

  useEffect(() => {
    const decoratedContentClickListener = {
      type: "click",
      listener: (evt: Event) => {
        const wordElement = evt.srcElement as HTMLElement;
        if (!wordElement) {
          return;
        }
        const clickedWord = (wordElement.textContent || "").toLowerCase();
        postDecoratedContentEvent({type: "click", text: clickedWord, bounds: wordElement.getBoundingClientRect()});
      }
    };
    addEventListeners(kClassName, decoratedContentClickListener);
    return () => removeEventListeners(kClassName, decoratedContentClickListener);
  });

  return [options, kClassName];
};
