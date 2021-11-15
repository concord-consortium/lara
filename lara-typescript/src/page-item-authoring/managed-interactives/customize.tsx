import * as React from "react";
import { useState } from "react";
import { IManagedInteractive } from "./index";
import { ILibraryInteractive } from "../common/hooks/use-library-interactives";
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
    show_in_featured_question_report,
    linked_interactive_item_id
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
            name="linked_interactive_item_id"
            defaultValue={`${linked_interactive_item_id || ""}`}
          />
          <div className="warning">
            <em>Warning</em>: Please do not link to another interactive
            unless the interactive knows how to load prior work.
          </div>
        </fieldset>
        <fieldset>
          <legend>Featured Report</legend>
          <Checkbox
              id="show_in_featured_question_report"
              name="show_in_featured_question_report"
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
        inheritName="inherit_click_to_play_prompt"
        customName="custom_click_to_play_prompt"
        inherit={inheritClickToPlayPrompt}
        defaultLabel={`"${defaultPrompt}"`}
        onChange={setInheritClickToPlayPrompt}
      >
        <input
          type="text"
          name="custom_click_to_play_prompt"
          value={customClickToPlayPrompt}
          onChange={handleChangeCustomClickToPlayPrompt}
        />
      </CustomizableOption>

      <CustomizableOption
        label="Full Window"
        inheritName="inherit_full_window"
        customName="custom_full_window"
        inherit={inheritFullWindow}
        defaultLabel={libraryInteractive.full_window ? "Enabled" : "Disabled"}
        onChange={setInheritFullWindow}
      >
        <Checkbox
          name="custom_full_window"
          defaultChecked={custom_full_window}
          label="Enabled"
        />
      </CustomizableOption>

      <CustomizableOption
        label="Image Url"
        inheritName="inherit_image_url"
        customName="custom_image_url"
        inherit={inheritImageUrl}
        defaultLabel={libraryInteractive.image_url ? libraryInteractive.image_url : "No default image url"}
        onChange={setInheritImageUrl}
      >
        <input
          type="text"
          name="custom_image_url"
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
        name="custom_aspect_ratio_method"
        value={customAspectRatioValues.mode}
      />
      <input
        type="hidden"
        name="inherit_native_width"
        value={inheritAspectRatio ? "true" : "false"}
      />
      <input
        type="hidden"
        name="custom_native_width"
        value={customAspectRatioValues.width}
      />
      <input
        type="hidden"
        name="inherit_native_height"
        value={inheritAspectRatio ? "true" : "false"}
      />
      <input
        type="hidden"
        name="custom_native_height"
        value={customAspectRatioValues.height}
      />
      <input
        type="radio"
        name="inherit_aspect_ratio_method"
        value="true"
        defaultChecked={inheritAspectRatio}
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
          name="inherit_aspect_ratio_method"
          value="false"
          defaultChecked={!inheritAspectRatio}
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
            name="inherit_click_to_play"
            value="true"
            defaultChecked={inheritClickToPlay}
            onChange={handleChangeClickToPlay}
          />
          <span className="radio-label">
            Use default: <strong>{libraryInteractive.click_to_play ? "Enabled" : "Disabled"}</strong>
          </span>
        </div>
        <div className="customizable-option">
          <input
            type="radio"
            name="inherit_click_to_play"
            value="false"
            defaultChecked={!inheritClickToPlay}
            onChange={handleChangeClickToPlay}
          />
          <span className="radio-label">Customize</span>
          {!inheritClickToPlay
            ? <>
                <input
                  type="checkbox"
                  name="custom_click_to_play"
                  value="true"
                  defaultChecked={customClickToPlay}
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
