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
import { DataSourceInteractive } from "../common/components/data-source-interactive";

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
    custom_click_to_play_prompt,
    inherit_full_window,
    custom_full_window,
    inherit_image_url,
    custom_image_url,
    linked_interactive_item_id,
    inherit_hide_question_number,
    custom_hide_question_number,
    inherit_save_interactive_state_history,
    custom_save_interactive_state_history,
    linked_interactives
  } = managedInteractive;

  const [inheritAspectRatio, setInheritAspectRatio] = useState(inherit_aspect_ratio_method);
  const [customAspectRatioValues, setCustomAspectRatioValues] = useState<IAspectRatioChooserValues>({
    width: custom_native_width,
    height: custom_native_height,
    mode: (custom_aspect_ratio_method || "DEFAULT") as AspectRatioMode
  });
  const [inheritClickToPlay, setInheritClickToPlay] = useState(inherit_click_to_play);
  const [customClickToPlay, setCustomClickToPlay] = useState(custom_click_to_play);
  const [customClickToPlayPrompt, setCustomClickToPlayPrompt] = useState(custom_click_to_play_prompt);
  const [inheritFullWindow, setInheritFullWindow] = useState(inherit_full_window);
  const [inheritImageUrl, setInheritImageUrl] = useState(inherit_image_url);
  const [customImageUrl, setCustomImageUrl] = useState(custom_image_url);
  const [inheritHideQuestionNumber, setInheritHideQuestionNumber] = useState(inherit_hide_question_number);
  const [customHideQuestionNumber, setCustomHideQuestionNumber] = useState(custom_hide_question_number);
  const [inheritSaveInteractiveStateHistory, setInheritSaveInteractiveStateHistory] =
    useState(inherit_save_interactive_state_history);
  const [customSaveInteractiveStateHistory, setCustomSaveInteractiveStateHistory] =
    useState(custom_save_interactive_state_history);

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
  const handleChangeHideQuestionNumber = handleBooleanOption(setInheritHideQuestionNumber);
  const handleChangeCustomHideQuestionNumber = handleBooleanOption(setCustomHideQuestionNumber);
  const handleChangeSaveInteractiveStateHistory = handleBooleanOption(setInheritSaveInteractiveStateHistory);
  const handleChangeCustomSaveInteractiveStateHistory = handleBooleanOption(setCustomSaveInteractiveStateHistory);

  const clickToPlayEnabled = (inheritClickToPlay && libraryInteractive.click_to_play) ||
                             (!inheritClickToPlay && customClickToPlay);

  const renderCommonTopFields = () => {
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
      </>
      : undefined}
    </>;
  };

  const renderCommonBottomFields = () => {
    return <>
      <DataSourceInteractive linked_interactives={linked_interactives} />
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
        {renderCommonTopFields()}
        {renderCommonBottomFields()}

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
      <div className="customizable-option-setting">
        <strong>Default Prompt Text</strong>
        <span className="default-click-to-play-prompt">{defaultPrompt}</span>
      </div>
      <div className="customizable-option-setting">
        <label htmlFor="custom-click-to-play-prompt">
          <strong>
            Custom Prompt Text
          </strong>
        </label>
        <input
          type="text"
          id="custom-click-to-play-prompt"
          name="custom_click_to_play_prompt"
          value={customClickToPlayPrompt}
          onChange={handleChangeCustomClickToPlayPrompt}
        />
      </div>

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
        label="Image URL"
        inheritName="inherit_image_url"
        customName="custom_image_url"
        inherit={inheritImageUrl}
        defaultLabel={libraryInteractive.image_url ? libraryInteractive.image_url : "No default image URL"}
        onChange={setInheritImageUrl}
      >
        <div className="customizable-option-setting">
          <label htmlFor="custom_image_url">Custom Image URL</label>
          <input
            type="text"
            id="custom_image_url"
            name="custom_image_url"
            value={customImageUrl}
            onChange={handleChangeCustomImageUrl}
          />
        </div>
      </CustomizableOption>
    </>;
  };

  // this generates a form element that renders inside the rails popup form
  return <>
    {renderCommonTopFields()}

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
        id="inherit-aspect-ratio-method-default"
        name="inherit_aspect_ratio_method"
        value="true"
        defaultChecked={inheritAspectRatio}
        onChange={handleChangeCustomizeAspectRatio}
      />
      <label htmlFor="inherit-aspect-ratio-method-default" className="radioLabel">
        Use default:
        <strong>
          {availableAspectRatios[libraryInteractive.aspect_ratio_method as AspectRatioMode]}
          {libraryInteractive.aspect_ratio_method === "MANUAL"
            ? ` (width: ${libraryInteractive.native_width}, height: ${libraryInteractive.native_height})`
            : undefined}
        </strong>
      </label>
      <div className="customizable-option">
        <input
          type="radio"
          id="inherit-aspect-ratio-method-customize"
          name="inherit_aspect_ratio_method"
          value="false"
          defaultChecked={!inheritAspectRatio}
          onChange={handleChangeCustomizeAspectRatio}
        />
        <label htmlFor="inherit-aspect-ratio-method-customize" className="radioLabel">
          Customize
          {!inheritAspectRatio &&
            <AspectRatioChooser
              width={customAspectRatioValues.width}
              height={customAspectRatioValues.height}
              mode={customAspectRatioValues.mode}
              onChange={handleAspectRatioChange}
            />
          }
        </label>
      </div>
    </fieldset>

    <fieldset>
      <legend>Click to Play</legend>
      <div className="option_group">
        <div className="customizable-option">
          <input
            type="radio"
            id="inherit-click-to-play-default"
            name="inherit_click_to_play"
            value="true"
            defaultChecked={inheritClickToPlay}
            onChange={handleChangeClickToPlay}
          />
          <label htmlFor="inherit-click-to-play-default" className="radioLabel">
            Use default: <strong>{libraryInteractive.click_to_play ? "Enabled" : "Disabled"}</strong>
          </label>
        </div>
        <div className="customizable-option">
          <input
            type="radio"
            id="inherit-click-to-play-customize"
            name="inherit_click_to_play"
            value="false"
            defaultChecked={!inheritClickToPlay}
            onChange={handleChangeClickToPlay}
          />
          <label htmlFor="inherit-click-to-play-customize" className="radioLabel">
            Customize
          </label>
          {!inheritClickToPlay &&
            <div className="customizable-option-setting">
              <input
                id="custom-click-to-play"
                type="checkbox"
                name="custom_click_to_play"
                value="true"
                defaultChecked={customClickToPlay}
                onChange={handleChangeCustomClickToPlay}
              />
              <label htmlFor="custom-click-to-play">
                Enabled
              </label>
            </div>
          }
          {clickToPlayEnabled && renderClickToPlayOptions()}
        </div>
      </div>
    </fieldset>

    {libraryInteractive.enable_learner_state &&
    <fieldset>
      <legend>Hide Question Number</legend>
      <div className="option_group">
        <div className="customizable-option">
          <input
            type="radio"
            id="inherit-hide-question-number-default"
            name="inherit_hide_question_number"
            value="true"
            defaultChecked={inheritHideQuestionNumber}
            onChange={handleChangeHideQuestionNumber}
          />
          <label htmlFor="inherit-hide-question-number-default" className="radioLabel">
            Use default: <strong>{libraryInteractive.hide_question_number ? "Enabled" : "Disabled"}</strong>
          </label>
        </div>
        <div className="customizable-option">
          <input
            type="radio"
            id="inherit-hide-question-number-customize"
            name="inherit_hide_question_number"
            value="false"
            defaultChecked={!inheritHideQuestionNumber}
            onChange={handleChangeHideQuestionNumber}
          />
          <label htmlFor="inherit-hide-question-number-customize" className="radioLabel">
            Customize
          </label>
          {!inheritHideQuestionNumber &&
            <div className="customizable-option-setting">
              <input
                id="custom-hide-question-number"
                type="checkbox"
                name="custom_hide_question_number"
                value="true"
                defaultChecked={customHideQuestionNumber}
                onChange={handleChangeCustomHideQuestionNumber}
              />
              <label htmlFor="custom-hide-question-number">
                Enabled
              </label>
            </div>
          }
        </div>
      </div>
    </fieldset>
    }

    {libraryInteractive.enable_learner_state &&
    <fieldset>
      <legend>Save Answer History</legend>
      <div className="option_group">
        <div className="customizable-option">
          <input
            type="radio"
            id="inherit-save-interactive-state-history-default"
            name="inherit_save_interactive_state_history"
            value="true"
            defaultChecked={inheritSaveInteractiveStateHistory}
            onChange={handleChangeSaveInteractiveStateHistory}
          />
          <label htmlFor="inherit-save-interactive-state-history-default" className="radioLabel">
            Use default: <strong>{libraryInteractive.save_interactive_state_history ? "Enabled" : "Disabled"}</strong>
          </label>
        </div>
        <div className="customizable-option">
          <input
            type="radio"
            id="inherit-save-interactive-state-history-customize"
            name="inherit_save_interactive_state_history"
            value="false"
            defaultChecked={!inheritSaveInteractiveStateHistory}
            onChange={handleChangeSaveInteractiveStateHistory}
          />
          <label htmlFor="inherit-save-interactive-state-history-customize" className="radioLabel">
            Customize
          </label>
          {!inheritSaveInteractiveStateHistory &&
            <div className="customizable-option-setting">
              <input
                id="custom-save-interactive-state-history"
                type="checkbox"
                name="custom_save_interactive_state_history"
                value="true"
                defaultChecked={customSaveInteractiveStateHistory}
                onChange={handleChangeCustomSaveInteractiveStateHistory}
              />
              <label htmlFor="custom-save-interactive-state-history">
                Enabled
              </label>
            </div>
          }
        </div>
      </div>
    </fieldset>
    }

    {renderCommonBottomFields()}
  </>;
};
