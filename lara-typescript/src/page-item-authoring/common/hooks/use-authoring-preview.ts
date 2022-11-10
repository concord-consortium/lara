import { ILinkedInteractive, ISetLinkedInteractives } from "@concord-consortium/interactive-api-host";
import { RefObject, useCallback, useEffect, useState } from "react";
import { debounce } from "ts-debounce";

interface IInteractiveBase {
  url?: string | null;
  authored_state: string;
  linked_interactives: ILinkedInteractive[];
}

interface IPreviewUpdate {
  newAuthoredState: string | object;
  newUrl?: string | null;
  newLinkedInteractives?: ILinkedInteractive[];
}

interface IOptions {
  interactive: IInteractiveBase;
  interactiveAuthoredStateRef: RefObject<HTMLTextAreaElement>;
  linkedInteractivesRef: RefObject<HTMLTextAreaElement>;
  handleUpdateItemPreview?: (updates: Record<string, any>) => void;
}

export const useAuthoringPreview = (options: IOptions) => {
  const { interactive, handleUpdateItemPreview, interactiveAuthoredStateRef, linkedInteractivesRef } = options;

  const [url, setUrl] = useState(interactive.url);
  const [authoredState, setAuthoredState] = useState(interactive.authored_state);
  const [linkedInteractives, setLinkedInteractives] =
    useState<ILinkedInteractive[] | undefined>(interactive.linked_interactives);

  const _updatePreview = ({ newAuthoredState, newLinkedInteractives, newUrl }: IPreviewUpdate) => {
    handleUpdateItemPreview?.({
      authoredState: typeof newAuthoredState === "string" ? newAuthoredState : JSON.stringify(newAuthoredState),
      linkedInteractives: newLinkedInteractives,
      url: newUrl
    });
  };

  const updatePreview = useCallback(debounce(_updatePreview, 500), []);

  useEffect(() => {
    updatePreview({ newAuthoredState: authoredState, newLinkedInteractives: linkedInteractives, newUrl: url });
  }, [authoredState, linkedInteractives, url]);

  const handleUrlChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    const interactiveUrl = e.target.value;
    setUrl(interactiveUrl);
  };

  const handleAuthoredStateChange = (newAuthoredState: string | object) => {
    if (interactiveAuthoredStateRef.current) {
      const jsonValue = typeof newAuthoredState === "string" ? newAuthoredState : JSON.stringify(newAuthoredState);
      interactiveAuthoredStateRef.current.value = jsonValue;
      setAuthoredState(jsonValue);
    }
  };

  const handleLinkedInteractivesChange = (newLinkedInteractives: ISetLinkedInteractives) => {
    if (linkedInteractivesRef.current) {
      linkedInteractivesRef.current.value = JSON.stringify(newLinkedInteractives);
      setLinkedInteractives(newLinkedInteractives.linkedInteractives);
    }
  };

  return {
    url,
    handleUrlChange,
    handleAuthoredStateChange,
    handleLinkedInteractivesChange
  };
};
