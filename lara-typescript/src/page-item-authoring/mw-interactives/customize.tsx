import * as React from "react";
import { useEffect, useState } from "react";
import { IMWInteractive } from "./index";
import { AspectRatioChooser,
         AspectRatioMode,
         IAspectRatioChooserValues
       } from "../common/components/aspect-ratio-chooser";
import { Checkbox } from "../common/components/checkbox";

interface Props {
  checkboxHandler?: (name: string, checked: boolean) => void;
  defaultClickToPlayPrompt: string;
  enableLearnerStateRef: any;
  interactive: IMWInteractive;
}

export const CustomizeMWInteractive: React.FC<Props> = (props) => {
  const {
    checkboxHandler,
    defaultClickToPlayPrompt,
    enableLearnerStateRef,
    interactive
  } = props;
  const {
    native_width,
    native_height,
    enable_learner_state,
    show_delete_data_button,
    has_report_url,
    click_to_play,
    click_to_play_prompt,
    full_window,
    image_url,
    show_in_featured_question_report,
    aspect_ratio_method,
    linked_interactive_id,
    linked_interactive_type,
    linked_interactive_item_id,
    report_item_url
  } = interactive;

  const [aspectRatioValues, setAspectRatioValues] = useState<IAspectRatioChooserValues>({
    width: native_width,
    height: native_height,
    mode: (aspect_ratio_method || "DEFAULT") as AspectRatioMode
  });

  const [state, setState] = useState({
    aspect_ratio_method,
    click_to_play,
    enable_learner_state,
    native_height,
    native_width,
  });

  const [reportItemURL, setReportItemURL] = useState(report_item_url);

  useEffect(() => {
    setState(currentState => ({
      ...currentState,
      aspect_ratio_method: aspectRatioValues.mode,
      native_height: aspectRatioValues.height,
      native_width: aspectRatioValues.width
    }));
  }, [aspectRatioValues]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setState(currentState => ({
      ...currentState,
      [name]: value,
    }));
  };

  const handleCheckboxChange = (name: string, checked: boolean) => {
    setState(currentState => ({
      ...currentState,
      [name]: checked
    }));
    checkboxHandler?.(name, checked);
  };

  const handleChangeReportItemURL = (event: React.ChangeEvent<HTMLInputElement>) => {
    setReportItemURL(event.target.value);
  };

  const renderClickToPlayOptions = () => {
    return <>
      <div>
        <Checkbox
          name="full_window"
          defaultChecked={full_window}
          label="Full window"
          onChange={handleCheckboxChange}
        />
      </div>

      <fieldset>
        <legend>Click To Play Prompt</legend>
        <input
          type="text"
          name="click_to_play_prompt"
          defaultValue={click_to_play_prompt || defaultClickToPlayPrompt}
          onChange={handleChange}
        />
      </fieldset>

      <fieldset>
        <legend>Image URL</legend>
        <input
          type="text"
          name="image_url"
          defaultValue={image_url}
          onChange={handleChange}
        />
        <br/>
        <div className="warning">
          <em>Warning</em>: Please provide an image url to use click to play.
        </div>
      </fieldset>
    </>;
  };

  const renderInteractiveStateOptions = () => {
    return <>
      <div>
        <Checkbox
          name="show_delete_data_button"
          defaultChecked={show_delete_data_button}
          label={`Show "Clear & start over" button`}
        />
      </div>

      <div>
        <Checkbox
          name="has_report_url"
          defaultChecked={has_report_url}
          label="This interactive has a report URL"
          warning="Please do not select this unless your interactive includes a report url in its saved state."
        />
      </div>

      <div>
        <Checkbox
          name="show_in_featured_question_report"
          defaultChecked={show_in_featured_question_report}
          label="Show in featured question report"
        />
      </div>

      <fieldset>
        <legend>Link Saved Work From</legend>
        <input
          type="text"
          name="linked_interactive_item_id"
          defaultValue={`${linked_interactive_item_id || ""}`}
        />
        <div className="warning">
          <em>Warning</em>: Please do not link to another interactive
          unless the interactive knows how to load prior work.
        </div>
      </fieldset>

      <fieldset>
        <legend>Report Item URL</legend>
        <input
          type="text"
          name="report_item_url"
          onChange={handleChangeReportItemURL}
          defaultValue={reportItemURL}
        />
        <div className="warning">
          This URL should point to an optional interactive used by the teacher report
          to provide a summary of each interactive answer to teachers. The value should
          be a partial URL relative to the iFrame interactive's URL.
        </div>
      </fieldset>
    </>;
  };

  // this generates a form element that renders inside the rails popup form
  return <>
    <fieldset>
      <legend>Aspect Ratio</legend>
      <input
        type="hidden"
        name="aspect_ratio_method"
        value={aspectRatioValues.mode}
      />
      <input
        type="hidden"
        name="native_width"
        value={aspectRatioValues.width}
      />
      <input
        type="hidden"
        name="native_height"
        value={aspectRatioValues.height}
      />
      <AspectRatioChooser
        width={aspectRatioValues.width}
        height={aspectRatioValues.height}
        mode={aspectRatioValues.mode}
        onChange={setAspectRatioValues}
      />
    </fieldset>

    <fieldset>
      <legend>Click to Play Options</legend>
      <div className="option_group">
        <Checkbox
          name="click_to_play"
          defaultChecked={state.click_to_play}
          onChange={handleCheckboxChange}
          label="Enable click to play"
        />
        {state.click_to_play ? renderClickToPlayOptions() : undefined}
      </div>
    </fieldset>

    <fieldset>
      <legend>Interactive State Options</legend>
      <div className="option_group">
        <Checkbox
          checkboxRef={enableLearnerStateRef}
          name="enable_learner_state"
          defaultChecked={state.enable_learner_state}
          onChange={handleCheckboxChange}
          label="Enable save state"
          warning="Please do not select this unless your interactive contains a serializable data set"
        />
        {state.enable_learner_state ? renderInteractiveStateOptions() : undefined}
      </div>
    </fieldset>
  </>;
};
