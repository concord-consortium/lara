import * as React from "react";
import { useState, useRef } from "react";
import { Tabs, TabList, Tab, TabPanel} from "react-tabs";
import { ILibraryInteractive } from "../common/hooks/use-library-interactives";
import { InteractiveAuthoring } from "../common/components/interactive-authoring";
import { RailsFormField } from "../common/utils/rails-form-field";
import { CustomizeManagedInteractive } from "./customize";
import { Checkbox } from "../common/components/checkbox";
import { useCurrentUser } from "../common/hooks/use-current-user";
import { AuthoredState } from "../common/components/authored-state";
import { AuthoringApiUrls } from "../common/types";
import { ILinkedInteractive, ISetLinkedInteractives } from "../../interactive-api-client";
import { saveAuthoredPluginState } from "../../plugins/plugin-context";

import "react-tabs/style/react-tabs.css";

interface Props {
  managedInteractive: IManagedInteractive;
  libraryInteractive?: ILibraryInteractive;
  defaultClickToPlayPrompt: string;
  authoringApiUrls: AuthoringApiUrls;
  onUpdate?: (updates: Partial<IManagedInteractive>) => void;
}

interface ISelectOption {
  value: number;
  label: string;
}

export interface IManagedInteractive {
  id: number;
  library_interactive_id: number;
  name: string;
  url_fragment: string;
  authored_state: string;
  is_hidden: boolean;
  is_full_width: boolean;
  aspect_ratio: number;
  enable_learner_state: boolean;
  linked_interactive_id: number;
  linked_interactive_type: string;
  show_in_featured_question_report: boolean;
  inherit_aspect_ratio_method: boolean;
  custom_aspect_ratio_method: string;
  inherit_native_width: boolean;
  custom_native_width: number;
  inherit_native_height: boolean;
  custom_native_height: number;
  inherit_click_to_play: boolean;
  custom_click_to_play: boolean;
  inherit_full_window: boolean;
  custom_full_window: boolean;
  inherit_click_to_play_prompt: boolean;
  custom_click_to_play_prompt: string;
  inherit_image_url: boolean;
  custom_image_url: string;
  interactive_item_id: string;
  linked_interactive_item_id: string;
  linked_interactives: ILinkedInteractive[];
}

const formField = RailsFormField<IManagedInteractive>("managed_interactive");

export const ManagedInteractiveAuthoring: React.FC<Props> = (props) => {
  const { managedInteractive, defaultClickToPlayPrompt, authoringApiUrls, onUpdate } = props;
  const [libraryInteractive, setLibraryInteractive] = useState<ILibraryInteractive|undefined>(props.libraryInteractive);
  const libraryInteractiveIdRef = useRef<HTMLInputElement|null>(null);
  const libraryInteractiveAuthoredStateRef = useRef<HTMLInputElement|null>(null);
  const linkedInteractivesRef = useRef<HTMLInputElement|null>(null);
  const [urlFragment, setUrlFragment] = useState(managedInteractive.url_fragment);
  const [name, setName] = useState(managedInteractive.name);
  const nameRef = useRef<HTMLInputElement|null>(null);
  const [isFullWidth, setIsFullWidth] = useState(managedInteractive.is_full_width);
  const isFullWidthRef = useRef<HTMLInputElement|null>(null);
  const [authoredState, setAuthoredState] = useState(managedInteractive.authored_state);
  const user = useCurrentUser();

  // Noah and Ethan were confused about how this form works.
  // Changes to fields in the InteractiveAuthoring component
  // seemed to clobber any changes to the name and full width
  // fields and to this component's state variables. We added
  // refs for name and full width and used those here. We pass
  // a value for newAuthoredState because the authored state
  // ref is not available here like the other refs are.
  const handleUpdate = (newAuthoredState: any) => {
    const updates = {
      name: nameRef.current?.value,
      is_full_width: isFullWidthRef.current?.checked,
      authored_state: newAuthoredState
    };
    onUpdate?.(updates);
  };

  const handleUrlFragmentBlur = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setUrlFragment(e.target.value);
  };

  const handleIsFullWidthChange = (isFullWidthVal: boolean) => {
    setIsFullWidth(isFullWidthVal);
    handleUpdate(authoredState);
  };

  const handleNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setName(e.target.value);
    handleUpdate(authoredState);
  };

  const renderRequiredFields = () => {
    if (!libraryInteractive) {
      return undefined;
    }

    return <>
      <fieldset>
        <label htmlFor={formField("name").id}>Name</label>
        <input
          ref={nameRef}
          type="text"
          id={formField("name").id}
          name={formField("name").name}
          defaultValue={name}
          onChange={handleNameChange}
        />
      </fieldset>

      <fieldset>
        <Checkbox
          checkboxRef={isFullWidthRef}
          id={formField("is_full_width").id}
          name={formField("is_full_width").name}
          defaultChecked={isFullWidth}
          label="Full width? (Full width layout only)"
          onChange={handleIsFullWidthChange}
        />
      </fieldset>
    </>;
  };

  const renderTabs = () => {
    if (!libraryInteractive) {
      return undefined;
    }

    const interactive = {
      url: `${libraryInteractive.base_url}${urlFragment || ""}`,
      aspect_ratio: managedInteractive.aspect_ratio,
      aspect_ratio_method: managedInteractive.inherit_aspect_ratio_method
        ? libraryInteractive.aspect_ratio_method
        : managedInteractive.custom_aspect_ratio_method,
      authored_state: managedInteractive.authored_state,
      interactive_item_id: managedInteractive.interactive_item_id,
      linked_interactives: managedInteractive.linked_interactives
    };

    const handleAuthoredStateChange = (newAuthoredState: string | object) => {
      if (libraryInteractiveAuthoredStateRef.current) {
        const jsonValue = libraryInteractiveAuthoredStateRef.current.value = typeof newAuthoredState === "string"
          ? newAuthoredState
          : JSON.stringify(newAuthoredState);
        setAuthoredState(jsonValue);
        handleUpdate(jsonValue);
      }
    };

    const handleLinkedInteractivesChange = (newLinkedInteractives: ISetLinkedInteractives) => {
      if (linkedInteractivesRef.current) {
        linkedInteractivesRef.current.value = JSON.stringify(newLinkedInteractives);
      }
    };

    const renderAuthoringPanel = () => {
      const { url_fragment } = managedInteractive;

      return (<>
        {libraryInteractive.authorable
          ? <InteractiveAuthoring
              interactive={interactive}
              onAuthoredStateChange={handleAuthoredStateChange}
              onLinkedInteractivesChange={handleLinkedInteractivesChange}
              allowReset={false}
              authoringApiUrls={authoringApiUrls}
            />
          : <>
              <fieldset>
                <legend>URL Fragment</legend>
                <textarea
                  id={formField("url_fragment").id}
                  name={formField("url_fragment").name}
                  defaultValue={url_fragment}
                  onBlur={handleUrlFragmentBlur}
                />
              </fieldset>
              {libraryInteractive.authoring_guidance
                ? <fieldset>
                    <legend>Authoring Guidance</legend>
                    <div dangerouslySetInnerHTML={{__html: libraryInteractive.authoring_guidance}} />
                  </fieldset>
                : undefined
              }
            </>
        }
      </>);
    };

    return (
      <Tabs>
        <TabList>
          <Tab>Authoring</Tab>
          <Tab>Advanced Options</Tab>
          {user?.isAdmin ? <Tab>Authored State (Admin Only)</Tab> : undefined}
        </TabList>
        <TabPanel forceRender={true}>
          {renderAuthoringPanel()}
        </TabPanel>
        <TabPanel forceRender={true}>
          <CustomizeManagedInteractive
            libraryInteractive={libraryInteractive}
            managedInteractive={managedInteractive}
            defaultClickToPlayPrompt={defaultClickToPlayPrompt}
          />
        </TabPanel>
        {user?.isAdmin
          ? <TabPanel forceRender={true}>
              <AuthoredState
                id={formField("authored_state").id}
                name={formField("authored_state").name}
                authoredState={interactive.authored_state}
              />
            </TabPanel>
          : undefined}
      </Tabs>
    );
  };

  // this generates a form element that renders inside the rails popup form
  return <>
    {<fieldset>
      <input
        type="hidden"
        id={formField("library_interactive_id").id}
        name={formField("library_interactive_id").name}
        ref={libraryInteractiveIdRef}
        defaultValue={libraryInteractive ? `${libraryInteractive.id}` : ""}
      />
      <input
        type="hidden"
        id={formField("authored_state").id}
        name={formField("authored_state").name}
        ref={libraryInteractiveAuthoredStateRef}
        defaultValue={managedInteractive.authored_state}
      />
      <input
        type="hidden"
        id={formField("linked_interactives").id}
        name={formField("linked_interactives").name}
        ref={linkedInteractivesRef}
      />
    </fieldset>}
    {renderRequiredFields()}
    {renderTabs()}
  </>;
};
