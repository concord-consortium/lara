import * as React from "react";
import { useRef } from "react";
import { Tabs, TabList, Tab, TabPanel} from "react-tabs";
import { InteractiveAuthoring } from "../common/components/interactive-authoring";
import { CustomizeMWInteractive } from "./customize";
import { Checkbox } from "../common/components/checkbox";
import { useCurrentUser } from "../common/hooks/use-current-user";
import { AuthoredState } from "../common/components/authored-state";
import { AuthoringApiUrls } from "../common/types";
import { ILinkedInteractive } from "../../interactive-api-client";
import { useAuthoringPreview } from "../common/hooks/use-authoring-preview";

import "react-tabs/style/react-tabs.css";

interface Props {
  interactive: IMWInteractive;
  defaultClickToPlayPrompt: string;
  authoringApiUrls: AuthoringApiUrls;
  handleUpdateItemPreview?: (updates: Record<string, any>) => void;
}

export interface IMWInteractive {
  name: string;
  url: string | null;
  native_width: number;
  native_height: number;
  enable_learner_state: boolean;
  hide_question_number: boolean;
  save_interactive_state_history: boolean;
  show_delete_data_button: boolean;
  has_report_url: boolean;
  click_to_play: boolean;
  click_to_play_prompt: string;
  full_window: boolean;
  image_url: string;
  is_hidden: boolean;
  is_half_width: boolean;
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
  report_item_url: string;
  data_source_interactive_item_id: string;
}

export const MWInteractiveAuthoring: React.FC<Props> = (props) => {
  const {
    interactive,
    defaultClickToPlayPrompt,
    authoringApiUrls,
    handleUpdateItemPreview
  } = props;
  const interactiveAuthoredStateRef = useRef<HTMLTextAreaElement>(null);
  const linkedInteractivesRef = useRef<HTMLTextAreaElement>(null);
  const enableLearnerStateRef = useRef<HTMLInputElement>(null);

  const {
    url,
    handleAuthoredStateChange,
    handleLinkedInteractivesChange,
    handleUrlChange
  } = useAuthoringPreview({
    interactive,
    handleUpdateItemPreview,
    interactiveAuthoredStateRef,
    linkedInteractivesRef,
  });

  const user = useCurrentUser();

  const renderRequiredFields = () => {
    const { name, is_half_width, no_snapshots } = interactive;

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
          onChange={handleUrlChange}
        />
      </fieldset>

      <fieldset>
        <legend>Options</legend>
        <Checkbox
          id="is_half_width"
          name="is_half_width"
          defaultChecked={is_half_width}
          label="Half Width"
          inputNote="In full-width layout only."
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
    const authoredInteractive = {
      url: url || "",
      aspect_ratio: interactive.aspect_ratio,
      aspect_ratio_method: interactive.aspect_ratio_method,
      authored_state: interactive.authored_state,
      interactive_item_id: interactive.interactive_item_id,
      linked_interactives: interactive.linked_interactives
    };

    const hasAuthoringUrl = url && url.trim().length > 0;

    return (
      <Tabs>
        <TabList>
          <Tab>Authoring</Tab>
          <Tab>Advanced Options</Tab>
          {user?.isAdmin ? <Tab>Admin</Tab> : undefined}
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
    <div className="interactiveItemID">
      InteractiveID: {interactive.interactive_item_id}
    </div>
    <fieldset>
      <legend>Iframe Interactive</legend>
      <textarea
        id="authored_state"
        name="authored_state"
        ref={interactiveAuthoredStateRef}
        defaultValue={interactive.authored_state}
        style={{ display: "none "}}
      />
      <textarea
        id="linked_interactives"
        name="linked_interactives"
        ref={linkedInteractivesRef}
        style={{ display: "none "}}
      />
    </fieldset>

    {renderRequiredFields()}

    {renderTabs()}
  </>;
};
