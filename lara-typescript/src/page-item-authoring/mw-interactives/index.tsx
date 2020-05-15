import * as React from "react";
import { useRef, useState } from "react";
import { Tabs, TabList, Tab, TabPanel} from "react-tabs";

import { InteractiveAuthoring } from "../common/components/interactive-authoring";
import { RailsFormField } from "../common/utils/rails-form-field";
import { CustomizeMWInteractive } from "./customize";

import "react-tabs/style/react-tabs.css";

interface Props {
  interactive: IMWInteractive;
  defaultClickToPlayPrompt: string;
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
}

const formField = RailsFormField<IMWInteractive>("mw_interactive");

export const MWInteractiveAuthoring: React.FC<Props> = (props) => {
  const { interactive, defaultClickToPlayPrompt } = props;
  const interactiveAuthoredStateRef = useRef<HTMLInputElement|null>(null);
  const [authoringUrl, setAuthoringUrl] = useState(interactive.url);

  const handleUrlBlur = (e: React.ChangeEvent<HTMLTextAreaElement>) => setAuthoringUrl(e.target.value);

  const renderRequiredFields = () => {
    const { name, url, is_full_width, no_snapshots } = interactive;

    return <>
      <fieldset>
        <legend>Name</legend>
        <input
          type="text"
          id={formField("name").id}
          name={formField("name").name}
          defaultValue={name}
        />
      </fieldset>

      <fieldset>
        <legend>URL</legend>
        <textarea
          id={formField("url").id}
          name={formField("url").name}
          defaultValue={url || ""}
          onBlur={handleUrlBlur}
        />
      </fieldset>

      <fieldset>
        <legend>Options</legend>
        <input
          type="checkbox"
          id={formField("is_full_width").id}
          name={formField("is_full_width").name}
          defaultChecked={is_full_width}
        /> Full width? (Full width layout only)
        <br />
        <input
          type="checkbox"
          id={formField("no_snapshots").id}
          name={formField("no_snapshots").name}
          defaultChecked={no_snapshots}
        /> Snapshots not supported
      </fieldset>
    </>;
  };

  const renderTabs = () => {
    const handleAuthoredStateChange = (newAuthoredState: string | object) => {
      if (interactiveAuthoredStateRef.current) {
        interactiveAuthoredStateRef.current.value = typeof newAuthoredState === "string"
          ? newAuthoredState
          : JSON.stringify(newAuthoredState);
      }
    };

    const authoredInteractive = {
      url: authoringUrl || "",
      aspect_ratio: interactive.aspect_ratio,
      aspect_ratio_method: interactive.aspect_ratio_method,
      authored_state: interactive.authored_state
    };

    const hasAuthoringUrl = authoringUrl && authoringUrl.trim().length > 0;

    return (
      <Tabs>
        <TabList>
          <Tab>Authoring</Tab>
          <Tab>Advanced Options</Tab>
        </TabList>
        <TabPanel forceRender={true}>
          {hasAuthoringUrl
            ?
              <InteractiveAuthoring
                interactive={authoredInteractive}
                onAuthoredStateChange={handleAuthoredStateChange}
                allowReset={false}
              />
            : <div>Please enter an url above and then move the focus out of the url field.</div>
          }
        </TabPanel>
        <TabPanel forceRender={true}>
          <CustomizeMWInteractive
            interactive={interactive}
            defaultClickToPlayPrompt={defaultClickToPlayPrompt}
          />
        </TabPanel>
      </Tabs>
    );
  };

  // this generates a form element that renders inside the rails popup form
  return <>
    <fieldset>
      <legend>Iframe Interactive</legend>
      <input
        type="hidden"
        id={formField("authored_state").id}
        name={formField("authored_state").name}
        ref={interactiveAuthoredStateRef}
        defaultValue={interactive.authored_state}
      />
    </fieldset>

    {renderRequiredFields()}

    {renderTabs()}
  </>;
};
