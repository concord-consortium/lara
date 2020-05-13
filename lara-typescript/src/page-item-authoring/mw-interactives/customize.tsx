import * as React from "react";
import { useState, useRef } from "react";
import { IMWInteractive } from "./index";
import { RailsFormField } from "../common/utils/rails-form-field";
import { ReadOnlyFormField } from "../common/components/read-only-form-field";
import { AspectRatioChooser,
         AspectRatioMode,
         IAspectRatioChooserValues,
         availableAspectRatios
       } from "../common/components/aspect-ratio-chooser";

interface Props {
  interactive: IMWInteractive;
  defaultClickToPlayPrompt: string;
}

const formField = RailsFormField<IMWInteractive>("mw_interactive");

/*
        {interactive.enable_learner_state ?
           <><input
            type="checkbox"
            id={formField("show_in_featured_question_report").id}
            name={formField("show_in_featured_question_report").name}
            defaultChecked={interactive.show_in_featured_question_report}
          /> Show in featured question report?</>
          : undefined}
*/

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
    linked_interactive_id
  } = interactive;

  const [aspectRatioValues, setAspectRatioValues] = useState<IAspectRatioChooserValues>({
    width: native_width,
    height: native_height,
    mode: (aspect_ratio_method || "DEFAULT") as AspectRatioMode
  });
  const [clickToPlay, setClickToPlay] = useState(click_to_play);
  const [enableLearnerState, setEnableLearnerState] = useState(enable_learner_state);

  const handleBooleanOption = (setter: (value: boolean) => void) => {
    return (e: React.ChangeEvent<HTMLInputElement>) => {
      const value = !!(e.target.checked && (e.target.value === "true"));
      setter(value);
    };
  };

  const handleAspectRatioChange = (values: IAspectRatioChooserValues) => setAspectRatioValues(values);

  const handleChangeClickToPlay = handleBooleanOption(setClickToPlay);
  const handleChangeEnableLearnerState = handleBooleanOption(setEnableLearnerState);

  const renderClickToPlayOptions = () => {
    return <>
      <div>
        <input
          type="checkbox"
          name={formField("full_window").name}
          value="true"
          defaultChecked={full_window}
        /> Full window
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
        <input
          type="checkbox"
          name={formField("show_delete_data_button").name}
          value="true"
          defaultChecked={show_delete_data_button}
        /> Show "Undo all my work" button
      </div>

      <div>
        <input
          type="checkbox"
          name={formField("has_report_url").name}
          value="true"
          defaultChecked={has_report_url}
        /> This interactive has a report URL
        <div className="warning">
          <em>Warning</em>: Please do not select this unless your interactive includes a report url in its saved state.
        </div>
      </div>

      <div>
        <input
          type="checkbox"
          name={formField("show_in_featured_question_report").name}
          value="true"
          defaultChecked={show_in_featured_question_report}
        /> Show in featured question report
      </div>

      <fieldset>
        <legend>Link Saved Work From</legend>
        <input
          type="text"
          name={formField("linked_interactive_id").name}
          defaultValue={`${linked_interactive_id || ""}`}
        />
        <div className="warning">
          <em>Warning</em>: Please do not link to another interactive
          unless the interactive knows how to load prior work.
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
        onChange={handleAspectRatioChange}
      />
    </fieldset>

    <fieldset>
      <legend>Click to Play Options</legend>
      <div className="option_group">
        <input
          type="checkbox"
          name={formField("click_to_play").name}
          value="true"
          checked={clickToPlay}
          onChange={handleChangeClickToPlay}
        /> Enable click to play
        {clickToPlay ? renderClickToPlayOptions() : undefined}
      </div>
    </fieldset>

    <fieldset>
      <legend>Interactive State Options</legend>
      <div className="option_group">
        <input
          type="checkbox"
          name={formField("enable_learner_state").name}
          value="true"
          checked={enableLearnerState}
          onChange={handleChangeEnableLearnerState}
        /> Enable save state
        <div className="warning">
          <em>Warning</em>: Please do not select this unless your interactive contains a serializable data set.
        </div>
        {enableLearnerState ? renderInteractiveStateOptions() : undefined}
      </div>
    </fieldset>
  </>;
};
