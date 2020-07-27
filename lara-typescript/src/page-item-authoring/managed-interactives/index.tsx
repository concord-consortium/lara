import * as React from "react";
import { useState, useRef } from "react";
import Select from "react-select";
import { Tabs, TabList, Tab, TabPanel} from "react-tabs";

import { useLibraryInteractives, ILibraryInteractive } from "../common/hooks/use-library-interactives";
import { InteractiveAuthoring } from "../common/components/interactive-authoring";

import "react-tabs/style/react-tabs.css";
import { RailsFormField } from "../common/utils/rails-form-field";
import { CustomizeManagedInteractive } from "./customize";
import { Checkbox } from "../common/components/checkbox";
import { useCurrentUser } from "../common/hooks/use-current-user";
import { AuthoredState } from "../common/components/authored-state";
import { AuthoringApiUrls } from "../common/types";

interface Props {
  managedInteractive: IManagedInteractive;
  libraryInteractive?: ILibraryInteractive;
  defaultClickToPlayPrompt: string;
  authoringApiUrls: AuthoringApiUrls;
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
  page_item_id: number;
}

const formField = RailsFormField<IManagedInteractive>("managed_interactive");

export const ManagedInteractiveAuthoring: React.FC<Props> = (props) => {
  const { managedInteractive, defaultClickToPlayPrompt, authoringApiUrls } = props;
  const libraryInteractives = useLibraryInteractives();
  const [libraryInteractive, setLibraryInteractive] = useState<ILibraryInteractive|undefined>(props.libraryInteractive);
  const libraryInteractiveIdRef = useRef<HTMLInputElement|null>(null);
  const libraryInteractiveAuthoredStateRef = useRef<HTMLInputElement|null>(null);
  const [urlFragment, setUrlFragment] = useState(managedInteractive.url_fragment);
  const user = useCurrentUser();

  if (libraryInteractives.state === "loading") {
    return <div className="loading">Loading library ...</div>;
  }
  if (libraryInteractives.state === "error") {
    return <div className="error">{libraryInteractives.error}</div>;
  }

  const createSelectOption = (li: ILibraryInteractive) => ({value: li.id, label: li.name});
  const selectOptions = libraryInteractives.list.map(createSelectOption);
  const selectedOption = libraryInteractive ? createSelectOption(libraryInteractive) : undefined;

  const handleSelectChange = (newSelectedOption: ISelectOption) => {
    const selectedLibraryInteractive = libraryInteractives.list.find(li => li.id === newSelectedOption.value);
    if (selectedLibraryInteractive) {
      const confirmMessage = `Use ${selectedLibraryInteractive.name}?  Once selected it can't be changed.`;
      if (confirm(confirmMessage)) {
        setLibraryInteractive(selectedLibraryInteractive);
        if (libraryInteractiveIdRef.current) {
          libraryInteractiveIdRef.current.value = newSelectedOption.value.toString();
        }
      }
    }
  };

  const handleUrlFragmentBlur = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setUrlFragment(e.target.value);
  };

  const renderRequiredFields = () => {
    if (!libraryInteractive) {
      return undefined;
    }

    const { name, is_full_width } = managedInteractive;

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
        <legend>Options</legend>
        <Checkbox
          id={formField("is_full_width").id}
          name={formField("is_full_width").name}
          defaultChecked={is_full_width}
          label="Full width? (Full width layout only)"
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
      page_item_id: managedInteractive.page_item_id
    };

    const handleAuthoredStateChange = (newAuthoredState: string | object) => {
      if (libraryInteractiveAuthoredStateRef.current) {
        libraryInteractiveAuthoredStateRef.current.value = typeof newAuthoredState === "string"
          ? newAuthoredState
          : JSON.stringify(newAuthoredState);
      }
    };

    const renderAuthoringPanel = () => {
      const { url_fragment } = managedInteractive;

      return (<>
        {libraryInteractive.authorable
          ? <InteractiveAuthoring
              interactive={interactive}
              onAuthoredStateChange={handleAuthoredStateChange}
              allowReset={false}
              authoringApiUrls={authoringApiUrls}
            />
          : <>
              <fieldset>
                <legend>Url Fragment</legend>
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
    <fieldset>
      <legend>Library Interactive</legend>
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
      {selectedOption
        ? selectedOption.label
        : <Select value={selectedOption} onChange={handleSelectChange} options={selectOptions} />
      }
    </fieldset>

    {renderRequiredFields()}

    {renderTabs()}
  </>;
};
