import * as React from "react";
import { useState, useRef } from "react";
import { Tabs, TabList, Tab, TabPanel} from "react-tabs";
import { ILibraryInteractive } from "../common/hooks/use-library-interactives";
import { InteractiveAuthoring } from "../common/components/interactive-authoring";
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
  is_half_width: boolean;
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

export const ManagedInteractiveAuthoring: React.FC<Props> = (props) => {
  const { libraryInteractive, managedInteractive, defaultClickToPlayPrompt, authoringApiUrls, onUpdate } = props;
  const { name, is_half_width } = managedInteractive;
  const libraryInteractiveIdRef = useRef<HTMLInputElement|null>(null);
  const libraryInteractiveAuthoredStateRef = useRef<HTMLTextAreaElement|null>(null);
  const linkedInteractivesRef = useRef<HTMLTextAreaElement|null>(null);
  const [urlFragment, setUrlFragment] = useState(managedInteractive.url_fragment);
  const user = useCurrentUser();

  const handleUrlFragmentBlur = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setUrlFragment(e.target.value);
  };

  const renderRequiredFields = () => {
    if (!libraryInteractive) {
      return undefined;
    }

    return <>
      <fieldset>
        <label htmlFor="name">Name</label>
        <input
          type="text"
          id="name"
          name="name"
          defaultValue={name}
        />
      </fieldset>

      <fieldset>
        <Checkbox
          id="is_half_width"
          name="is_half_width"
          defaultChecked={is_half_width}
          label="Half width (Full width layout only)"
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
        libraryInteractiveAuthoredStateRef.current.value = typeof newAuthoredState === "string"
          ? newAuthoredState
          : JSON.stringify(newAuthoredState);
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
                  id="url_fragment"
                  name="url_fragment"
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
                id="authored_state"
                name="authored_state"
                authoredState={interactive.authored_state}
              />
            </TabPanel>
          : undefined}
      </Tabs>
    );
  };

  // this generates a form element that renders inside the rails popup form
  return <>
      <input
        type="hidden"
        id="library_interactive_id"
        name="library_interactive_id"
        ref={libraryInteractiveIdRef}
        defaultValue={libraryInteractive ? libraryInteractive.id : ""}
      />
      <textarea
        id="authored_state"
        name="authored_state"
        ref={libraryInteractiveAuthoredStateRef}
        defaultValue={managedInteractive.authored_state}
        style={{ display: "none" }}
      />
      <textarea
        id="linked_interactives"
        name="linked_interactives"
        ref={linkedInteractivesRef}
        style={{ display: "none" }}
      />
    {renderRequiredFields()}
    {renderTabs()}
  </>;
};
