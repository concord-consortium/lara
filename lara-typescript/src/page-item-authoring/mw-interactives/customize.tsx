import * as React from "react";
import { useState, useRef } from "react";
import { IMWInteractive } from "./index";
import { RailsFormField } from "../common/utils/rails-form-field";
import { AspectRatioChooser,
         AspectRatioMode,
         IAspectRatioChooserValues,
         availableAspectRatios
       } from "../common/components/aspect-ratio-chooser";
import { Checkbox } from "../common/components/checkbox";

interface Props {
  interactive: IMWInteractive;
  defaultClickToPlayPrompt: string;
}

const formField = RailsFormField<IMWInteractive>("mw_interactive");

export const CustomizeMWInteractive: React.FC<Props> = (props) => {
  const { interactive, defaultClickToPlayPrompt } = props;
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
  const [clickToPlay, setClickToPlay] = useState(click_to_play);
  const [enableLearnerState, setEnableLearnerState] = useState(enable_learner_state);
  const [reportItemURL, setReportItemURL] = useState(report_item_url);

  const handleChangeReportItemURL = (event: React.ChangeEvent<HTMLInputElement>) => {
    setReportItemURL(event.target.value);
  };

  const renderClickToPlayOptions = () => {
    return <>
      <div>
        <Checkbox
          name={formField("full_window").name}
          defaultChecked={full_window}
          label="Full window"
        />
      </div>

      <fieldset>
        <legend>Click To Play Prompt</legend>
        <input
          type="text"
          name={formField("click_to_play_prompt").name}
          defaultValue={click_to_play_prompt || defaultClickToPlayPrompt}
        />
      </fieldset>

      <fieldset>
        <legend>Image Url</legend>
        <input
          type="text"
          name={formField("image_url").name}
          defaultValue={image_url}
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
          name={formField("show_delete_data_button").name}
          defaultChecked={show_delete_data_button}
          label={`Show "Undo all my work" button`}
        />
      </div>

      <div>
        <Checkbox
          name={formField("has_report_url").name}
          defaultChecked={has_report_url}
          label="This interactive has a report URL"
          warning="Please do not select this unless your interactive includes a report url in its saved state."
        />
      </div>

      <div>
        <Checkbox
          name={formField("show_in_featured_question_report").name}
          defaultChecked={show_in_featured_question_report}
          label="Show in featured question report"
        />
      </div>

      <fieldset>
        <legend>Link Saved Work From</legend>
        <input
          type="text"
          name={formField("linked_interactive_item_id").name}
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
          name={formField("report_item_url").name}
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
        name={formField("aspect_ratio_method").name}
        value={aspectRatioValues.mode}
      />
      <input
        type="hidden"
        name={formField("native_width").name}
        value={aspectRatioValues.width}
      />
      <input
        type="hidden"
        name={formField("native_height").name}
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
          name={formField("click_to_play").name}
          checked={clickToPlay}
          onChange={setClickToPlay}
          label="Enable click to play"
        />
        {clickToPlay ? renderClickToPlayOptions() : undefined}
      </div>
    </fieldset>

    <fieldset>
      <legend>Interactive State Options</legend>
      <div className="option_group">
        <Checkbox
          name={formField("enable_learner_state").name}
          checked={enableLearnerState}
          onChange={setEnableLearnerState}
          label="Enable save state"
          warning="Please do not select this unless your interactive contains a serializable data set"
        />
        {enableLearnerState ? renderInteractiveStateOptions() : undefined}
      </div>
    </fieldset>
  </>;
};
