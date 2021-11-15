import * as React from "react";
import { useRef, useState } from "react";
import { Tabs, TabList, Tab, TabPanel} from "react-tabs";
import { InteractiveAuthoring } from "../common/components/interactive-authoring";
import { CustomizeMWInteractive } from "./customize";
import { Checkbox } from "../common/components/checkbox";
import { useCurrentUser } from "../common/hooks/use-current-user";
import { AuthoredState } from "../common/components/authored-state";
import { AuthoringApiUrls } from "../common/types";
import { ILinkedInteractive, ISetLinkedInteractives } from "../../interactive-api-client";
import "react-tabs/style/react-tabs.css";
import { valueContainerCSS } from "react-select/src/components/containers";

interface Props {
  interactive: IMWInteractive;
  defaultClickToPlayPrompt: string;
  authoringApiUrls: AuthoringApiUrls;
}

export interface IMWInteractive {
  name: string;
  url: string | null;
  native_width: number;
  native_height: number;
  enable_learner_state: boolean;
  show_delete_data_button: boolean;
  has_report_url: boolean;
  click_to_play: boolean;
  click_to_play_prompt: string;
  full_window: boolean;
  show_in_featured_question_report: boolean;
  image_url: string;
  is_hidden: boolean;
  is_full_width: boolean;
  model_library_url: string;
  authored_state: string;
  aspect_ratio: number;
  aspect_ratio_method: string;
  no_snapshots: boolean;
  linked_interactive_id: number;
  linked_interactive_type: string;
  interactive_item_id: string;
  linked_interactive_item_id: string;
  linked_interactives: ILinkedInteractive[];
}

export const MWInteractiveAuthoring: React.FC<Props> = (props) => {
  const { interactive, defaultClickToPlayPrompt, authoringApiUrls } = props;
  const interactiveAuthoredStateRef = useRef<HTMLInputElement|null>(null);
  const linkedInteractivesRef = useRef<HTMLInputElement|null>(null);
  const enableLearnerStateRef = useRef<HTMLInputElement|null>(null);
  const [authoredState, setAuthoredState] = useState(interactive.authored_state);
  const [authoringUrl, setAuthoringUrl] = useState(interactive.url);
  const user = useCurrentUser();

  const handleUrlBlur = (e: React.ChangeEvent<HTMLTextAreaElement>) => setAuthoringUrl(e.target.value);

  const renderRequiredFields = () => {
    const { name, url, is_full_width, no_snapshots } = interactive;

    return <>
      <fieldset>
        <legend>Name</legend>
        <input
          type="text"
          id="name"
          name="name"
          defaultValue={name}
        />
      </fieldset>

      <fieldset>
        <legend>URL</legend>
        <textarea
          id="url"
          name="url"
          defaultValue={url || ""}
          onBlur={handleUrlBlur}
        />
      </fieldset>

      <fieldset>
        <legend>Options</legend>
        <Checkbox
          id="is_full_width"
          name="is_full_width"
          defaultChecked={is_full_width}
          label="Full width? (Full width layout only)"
        />
        <br />
        <Checkbox
          id="no_snapshots"
          name="no_snapshots"
          defaultChecked={no_snapshots}
          label="Snapshots not supported"
        />
      </fieldset>
    </>;
  };

  const renderTabs = () => {
    const handleAuthoredStateChange = (newAuthoredState: string | object) => {
      if (interactiveAuthoredStateRef.current) {
        const jsonValue = interactiveAuthoredStateRef.current.value = typeof newAuthoredState === "string"
          ? newAuthoredState
          : JSON.stringify(newAuthoredState);
        setAuthoredState(jsonValue);
      }
    };

    const handleLinkedInteractivesChange = (newLinkedInteractives: ISetLinkedInteractives) => {
      if (linkedInteractivesRef.current) {
        linkedInteractivesRef.current.value = JSON.stringify(newLinkedInteractives);
      }
    };

    const authoredInteractive = {
      url: authoringUrl || "",
      aspect_ratio: interactive.aspect_ratio,
      aspect_ratio_method: interactive.aspect_ratio_method,
      authored_state: interactive.authored_state,
      interactive_item_id: interactive.interactive_item_id,
      linked_interactives: interactive.linked_interactives
    };

    const hasAuthoringUrl = authoringUrl && authoringUrl.trim().length > 0;

    return (
      <Tabs>
        <TabList>
          <Tab>Authoring</Tab>
          <Tab>Advanced Options</Tab>
          {user?.isAdmin ? <Tab>Authored State (Admin Only)</Tab> : undefined}
        </TabList>
        <TabPanel forceRender={true}>
          {hasAuthoringUrl
            ?
              <InteractiveAuthoring
                interactive={authoredInteractive}
                onAuthoredStateChange={handleAuthoredStateChange}
                onLinkedInteractivesChange={handleLinkedInteractivesChange}
                allowReset={false}
                authoringApiUrls={authoringApiUrls}
              />
            : <div>Please enter a URL above and then move the focus out of the URL field.</div>
          }
        </TabPanel>
        <TabPanel forceRender={true}>
          <CustomizeMWInteractive
            defaultClickToPlayPrompt={defaultClickToPlayPrompt}
            enableLearnerStateRef={enableLearnerStateRef}
            interactive={interactive}
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
    <fieldset>
      <legend>Iframe Interactive</legend>
      <input
        type="hidden"
        id="authored_state"
        name="authored_state"
        ref={interactiveAuthoredStateRef}
        defaultValue={interactive.authored_state}
      />
      <input
        type="hidden"
        id="linked_interactives"
        name="linked_interactives"
        ref={linkedInteractivesRef}
      />
    </fieldset>

    {renderRequiredFields()}

    {renderTabs()}
  </>;
};
