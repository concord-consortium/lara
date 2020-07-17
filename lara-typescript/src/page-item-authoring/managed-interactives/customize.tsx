import * as React from "react";
import { useState, useRef } from "react";
import { IManagedInteractive } from "./index";
import { ILibraryInteractive } from "../common/hooks/use-library-interactives";
import { RailsFormField } from "../common/utils/rails-form-field";
import { ReadOnlyFormField } from "../common/components/read-only-form-field";
import { AspectRatioChooser,
         AspectRatioMode,
         IAspectRatioChooserValues,
         availableAspectRatios
       } from "../common/components/aspect-ratio-chooser";
import { CustomizableOption } from "../common/components/customizable-option";
import { Checkbox } from "../common/components/checkbox";

interface Props {
  managedInteractive: IManagedInteractive;
  libraryInteractive: ILibraryInteractive;
  defaultClickToPlayPrompt: string;
}

const formField = RailsFormField<IManagedInteractive>("managed_interactive");

export const CustomizeManagedInteractive: React.FC<Props> = (props) => {
  const { managedInteractive, libraryInteractive, defaultClickToPlayPrompt } = props;
  const {
    inherit_aspect_ratio_method,
    custom_aspect_ratio_method,
    custom_native_width,
    custom_native_height,
    inherit_click_to_play,
    custom_click_to_play,
    inherit_click_to_play_prompt,
    custom_click_to_play_prompt,
    inherit_full_window,
    custom_full_window,
    inherit_image_url,
    custom_image_url,
    linked_interactive_id,
    show_in_featured_question_report
  } = managedInteractive;

  const [inheritAspectRatio, setInheritAspectRatio] = useState(inherit_aspect_ratio_method);
  const [customAspectRatioValues, setCustomAspectRatioValues] = useState<IAspectRatioChooserValues>({
    width: custom_native_width,
    height: custom_native_height,
    mode: (custom_aspect_ratio_method || "DEFAULT") as AspectRatioMode
  });
  const [inheritClickToPlay, setInheritClickToPlay] = useState(inherit_click_to_play);
  const [customClickToPlay, setCustomClickToPlay] = useState(custom_click_to_play);
  const [inheritClickToPlayPrompt, setInheritClickToPlayPrompt] = useState(inherit_click_to_play_prompt);
  const [customClickToPlayPrompt, setCustomClickToPlayPrompt] = useState(custom_click_to_play_prompt);
  const [inheritFullWindow, setInheritFullWindow] = useState(inherit_full_window);
  const [customFullWindow, setCustomFullWindow] = useState(custom_full_window);
  const [inheritImageUrl, setInheritImageUrl] = useState(inherit_image_url);
  const [customImageUrl, setCustomImageUrl] = useState(custom_image_url);

  const handleBooleanOption = (setter: (value: boolean) => void) => {
    return (e: React.ChangeEvent<HTMLInputElement>) => {
      const value = !!(e.target.checked && (e.target.value === "true"));
      setter(value);
    };
  };
  const handleStringOption = (setter: (value: string) => void) => {
    return (e: React.ChangeEvent<HTMLInputElement>) => {
      setter(e.target.value);
    };
  };

  const handleAspectRatioChange = (values: IAspectRatioChooserValues) => setCustomAspectRatioValues(values);

  const handleChangeCustomizeAspectRatio = handleBooleanOption(setInheritAspectRatio);
  const handleChangeClickToPlay = handleBooleanOption(setInheritClickToPlay);
  const handleChangeCustomClickToPlay = handleBooleanOption(setCustomClickToPlay);
  const handleChangeCustomClickToPlayPrompt = handleStringOption(setCustomClickToPlayPrompt);
  const handleChangeCustomImageUrl = handleStringOption(setCustomImageUrl);

  const clickToPlayEnabled = (inheritClickToPlay && libraryInteractive.click_to_play) ||
                             (!inheritClickToPlay && customClickToPlay);

  const renderCommonFields = () => {
    return <>
      {libraryInteractive.enable_learner_state ?
      <>
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
        <fieldset>
          <legend>Featured Report</legend>
          <Checkbox
              id={formField("show_in_featured_question_report").id}
              name={formField("show_in_featured_question_report").name}
              defaultChecked={show_in_featured_question_report}
              label="Show in featured question report?"
            />
        </fieldset>
      </>
      : undefined}
    </>;
  };

  if (!libraryInteractive.customizable) {
    const renderAspectRatioValues = () => {
      const mode = (inherit_aspect_ratio_method
        ? libraryInteractive.aspect_ratio_method
        : custom_aspect_ratio_method) as AspectRatioMode;

      if (mode !== "MANUAL") {
        return undefined;
      }

      const values = {
        width: inherit_aspect_ratio_method ? libraryInteractive.native_width : custom_native_width,
        height: inherit_aspect_ratio_method ? libraryInteractive.native_height : custom_native_height,
      };
      return <span style={{marginLeft: 10}}>(width: {values.width}, height: {values.height})</span>;
    };

    return (
      <div>
        {renderCommonFields()}

        <p>
          The selected library interactive ({libraryInteractive.name})
          does not support customizing the additional advanced options.
          Here are their values:
        </p>
        <ReadOnlyFormField
          legend="Aspect Ratio"
          value={availableAspectRatios[custom_aspect_ratio_method as AspectRatioMode]}
          inherit={true}
          inherited={inherit_aspect_ratio_method}
          inheritedValue={availableAspectRatios[libraryInteractive.aspect_ratio_method as AspectRatioMode]}
        >
          {renderAspectRatioValues()}
        </ReadOnlyFormField>
      </div>
    );
  }

  const renderClickToPlayOptions = () => {
    const defaultPrompt = libraryInteractive.click_to_play_prompt || defaultClickToPlayPrompt;
    return <>
      <CustomizableOption
        label="Click To Play Prompt"
        inheritName={formField("inherit_click_to_play_prompt").name}
        customName={formField("custom_click_to_play_prompt").name}
        inherit={inheritClickToPlayPrompt}
        defaultLabel={`"${defaultPrompt}"`}
        onChange={setInheritClickToPlayPrompt}
      >
        <input
          type="text"
          name={formField("custom_click_to_play_prompt").name}
          value={customClickToPlayPrompt}
          onChange={handleChangeCustomClickToPlayPrompt}
        />
      </CustomizableOption>

      <CustomizableOption
        label="Full Window"
        inheritName={formField("inherit_full_window").name}
        customName={formField("custom_full_window").name}
        inherit={inheritFullWindow}
        defaultLabel={libraryInteractive.full_window ? "Enabled" : "Disabled"}
        onChange={setInheritFullWindow}
      >
        <Checkbox
          name={formField("custom_full_window").name}
          checked={customFullWindow}
          onChange={setCustomFullWindow}
          label="Enabled"
        />
      </CustomizableOption>

      <CustomizableOption
        label="Image Url"
        inheritName={formField("inherit_image_url").name}
        customName={formField("custom_image_url").name}
        inherit={inheritImageUrl}
        defaultLabel={libraryInteractive.image_url ? libraryInteractive.image_url : "No default image url"}
        onChange={setInheritImageUrl}
      >
        <input
          type="text"
          name={formField("custom_image_url").name}
          value={customImageUrl}
          onChange={handleChangeCustomImageUrl}
        />
      </CustomizableOption>
    </>;
  };

  // this generates a form element that renders inside the rails popup form
  return <>
    {renderCommonFields()}

    <fieldset>
      <legend>Aspect Ratio</legend>
      <input
        type="hidden"
        name={formField("custom_aspect_ratio_method").name}
        value={customAspectRatioValues.mode}
      />
      <input
        type="hidden"
        name={formField("inherit_native_width").name}
        value={inheritAspectRatio ? "true" : "false"}
      />
      <input
        type="hidden"
        name={formField("custom_native_width").name}
        value={customAspectRatioValues.width}
      />
      <input
        type="hidden"
        name={formField("inherit_native_height").name}
        value={inheritAspectRatio ? "true" : "false"}
      />
      <input
        type="hidden"
        name={formField("custom_native_height").name}
        value={customAspectRatioValues.height}
      />
      <input
        type="radio"
        name={formField("inherit_aspect_ratio_method").name}
        value="true"
        checked={inheritAspectRatio}
        onChange={handleChangeCustomizeAspectRatio}
      />
      <span className="radio-label">Use default: </span>
      <strong>
        {availableAspectRatios[libraryInteractive.aspect_ratio_method as AspectRatioMode]}
        {libraryInteractive.aspect_ratio_method === "MANUAL"
          ? ` (width: ${libraryInteractive.native_width}, height: ${libraryInteractive.native_height})`
          : undefined}
      </strong>
      <div className="customizable-option">
        <input
          type="radio"
          name={formField("inherit_aspect_ratio_method").name}
          value="false"
          checked={!inheritAspectRatio}
          onChange={handleChangeCustomizeAspectRatio}
        />
        <span className="radio-label">Customize</span>
        {!inheritAspectRatio
          ? <AspectRatioChooser
              width={customAspectRatioValues.width}
              height={customAspectRatioValues.height}
              mode={customAspectRatioValues.mode}
              onChange={handleAspectRatioChange}
            />
          : undefined}
      </div>
    </fieldset>

    <fieldset>
      <legend>Click to Play Options</legend>
      <div className="option_group">
        <div className="customizable-label">Enable Click To Play</div>
        <div className="customizable-option">
          <input
            type="radio"
            name={formField("inherit_click_to_play").name}
            value="true"
            checked={inheritClickToPlay}
            onChange={handleChangeClickToPlay}
          />
          <span className="radio-label">
            Use default: <strong>{libraryInteractive.click_to_play ? "Enabled" : "Disabled"}</strong>
          </span>
        </div>
        <div className="customizable-option">
          <input
            type="radio"
            name={formField("inherit_click_to_play").name}
            value="false"
            checked={!inheritClickToPlay}
            onChange={handleChangeClickToPlay}
          />
          <span className="radio-label">Customize</span>
          {!inheritClickToPlay
            ? <>
                <input
                  type="checkbox"
                  name={formField("custom_click_to_play").name}
                  value="true"
                  checked={customClickToPlay}
                  onChange={handleChangeCustomClickToPlay}
                /> Enabled
              </>
            : undefined}
        </div>
        {clickToPlayEnabled ? renderClickToPlayOptions() : undefined}
      </div>
    </fieldset>
  </>;
};
