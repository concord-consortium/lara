import * as React from "react";
import { useState, useRef } from "react";
import Select from "react-select";
import { Tabs, TabList, Tab, TabPanel} from "react-tabs";

import { useLibraryInteractives, ILibraryInteractive } from "../common/hooks/use-library-interactives";
import { InteractiveAuthoring } from "../common/components/interactive-authoring";

import "react-tabs/style/react-tabs.css";
import { RailsFormField } from "../common/utils/rails-form-field";
import { CustomizeManagedInteractive } from "./customize";

interface Props {
  managedInteractive: IManagedInteractive;
  libraryInteractive?: ILibraryInteractive;
  defaultClickToPlayPrompt: string;
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
}

const formField = RailsFormField<IManagedInteractive>("managed_interactive");

export const ManagedInteractiveAuthoring: React.FC<Props> = (props) => {
  const { managedInteractive, defaultClickToPlayPrompt } = props;
  const libraryInteractives = useLibraryInteractives();
  const [libraryInteractive, setLibraryInteractive] = useState<ILibraryInteractive|undefined>(props.libraryInteractive);
  const libraryInteractiveIdRef = useRef<HTMLInputElement|null>(null);
  const libraryInteractiveAuthoredStateRef = useRef<HTMLInputElement|null>(null);
  const [urlFragment, setUrlFragment] = useState(managedInteractive.url_fragment);

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
    setLibraryInteractive(selectedLibraryInteractive);
    if (libraryInteractiveIdRef.current) {
      libraryInteractiveIdRef.current.value = newSelectedOption.value.toString();
    }
  };

  const handleUrlFragmentChange = (newUrlFragment: string) => setUrlFragment(newUrlFragment);

  const renderRequiredFields = () => {
    if (!libraryInteractive) {
      return undefined;
    }

    return <>
      <fieldset>
        <legend>Name</legend>
        <input
          type="text"
          id={formField("name").id}
          name={formField("name").name}
          defaultValue={managedInteractive.name}
        />
      </fieldset>

      <fieldset>
        <legend>Options</legend>
        <input
          type="checkbox"
          id={formField("is_full_width").id}
          name={formField("is_full_width").name}
          defaultChecked={managedInteractive.is_full_width}
        /> Full width? (Full width layout only)
        <br />
        {libraryInteractive.enable_learner_state ?
           <><input
            type="checkbox"
            id={formField("show_in_featured_question_report").id}
            name={formField("show_in_featured_question_report").name}
            defaultChecked={managedInteractive.show_in_featured_question_report}
          /> Show in featured question report?</>
          : undefined}
      </fieldset>
    </>;
  };

  const renderTabs = () => {
    if (!libraryInteractive) {
      return undefined;
    }

    const interactive = {
      url: `${libraryInteractive.base_url}${urlFragment || ""}`,
      aspect_ratio_method: managedInteractive.inherit_aspect_ratio_method
        ? libraryInteractive.aspect_ratio_method
        : managedInteractive.custom_aspect_ratio_method,
      authored_state: managedInteractive.authored_state
    };

    const handleAuthoredStateChange = (newAuthoredState: string | object) => {
      if (libraryInteractiveAuthoredStateRef.current) {
        libraryInteractiveAuthoredStateRef.current.value = typeof newAuthoredState === "string"
          ? newAuthoredState
          : JSON.stringify(newAuthoredState);
      }
    };

    return (
      <Tabs>
        <TabList>
          <Tab>Authoring</Tab>
          <Tab>Advanced Options</Tab>
        </TabList>
        <TabPanel forceRender={true}>
          {libraryInteractive.authorable
            ? <InteractiveAuthoring
                interactive={interactive}
                onAuthoredStateChange={handleAuthoredStateChange}
                allowReset={false}
              />
            : <p>The selected library interactive ({libraryInteractive.name}) does not support authoring.</p>
          }
        </TabPanel>
        <TabPanel forceRender={true}>
          <CustomizeManagedInteractive
            libraryInteractive={libraryInteractive}
            managedInteractive={managedInteractive}
            defaultClickToPlayPrompt={defaultClickToPlayPrompt}
            onUrlFragmentChange={handleUrlFragmentChange}
          />
        </TabPanel>
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
      <Select value={selectedOption} onChange={handleSelectChange} options={selectOptions} />
    </fieldset>

    {renderRequiredFields()}

    {renderTabs()}
  </>;
};