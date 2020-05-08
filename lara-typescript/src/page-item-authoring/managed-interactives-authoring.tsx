import * as React from "react";
import { useEffect, useState, useRef } from "react";
import Select from "react-select";

interface Props {
  selectLegend?: string;
  selectId?: string;
  selectName?: string;
  libraryInteractive?: ILibraryInteractive;
}

export interface ILibraryInteractive {
  id: number;
  name: string;
  aspect_ratio_method: string;
  authoring_guidance: string;
  base_url: string;
  click_to_play: boolean;
  click_to_play_prompt: string;
  description: string;
  enable_learner_state: boolean;
  export_hash: string;
  full_window: boolean;
  has_report_url: boolean;
  image_url: string;
  native_height: number;
  native_width: number;
  no_snapshots: boolean;
  show_delete_data_button: boolean;
  thumbnail_url: string;
  created_at: string;
  updated_at: string;
}

interface ISelectOption {
  value: number;
  label: string;
}

interface ILoadingState {
  current: "loading";
}
interface IErrorState {
  current: "error";
  error: string;
}
interface ILoadedState {
  current: "loaded";
  libraryInteractives: ILibraryInteractive[];
  selectedOption?: ISelectOption;
}
type ManagedInteractiveAuthoringState = ILoadingState | IErrorState | ILoadedState;

export const ManagedInteractiveAuthoring: React.FC<Props> = (props) => {
  const { libraryInteractive } = props;
  let { selectLegend, selectId, selectName } = props;
  const [state, setState] = useState<ManagedInteractiveAuthoringState>({current: "loading"});
  const hiddenRef = useRef<HTMLInputElement|null>(null);

  // load the list of interactives once at load time - this json is readable by admins and authors
  useEffect(() => {
    $.getJSON("/library_interactives")
    .done((libraryInteractives: ILibraryInteractive[]) => {
      setState({
        current: "loaded",
        libraryInteractives,
        selectedOption: libraryInteractive ? {value: libraryInteractive.id, label: libraryInteractive.name} : undefined
      });
    })
    .fail((jqxhr, textStatus, error) => {
      setState({current: "error", error: error.toString()});
    });
  }, []);

  if (state.current === "loading") {
    return <div className="loading">Loading library ...</div>;
  }
  if (state.current === "error") {
    return <div className="error">{state.error}</div>;
  }

  // default values
  selectLegend = selectLegend || "Library Interactive";
  selectId = selectId || "managed_interactive_library_interactive_id";
  selectName = selectName || "managed_interactive[library_interactive_id]";

  const selectOptions = state.libraryInteractives.map(li => ({value: li.id, label: li.name}));

  const handleSelectChange = (selectedOption: ISelectOption) => {
    setState({ ...state, selectedOption });
    if (hiddenRef.current) {
      hiddenRef.current.value = selectedOption.value.toString();
    }
  };

  // this generates a form element that renders inside the rails popup form
  return (
    <fieldset>
      <legend>{selectLegend}</legend>
      <input type="hidden" id={selectId} name={selectName} ref={hiddenRef} />
      <Select value={state.selectedOption} onChange={handleSelectChange} options={selectOptions} />
    </fieldset>
  );
};
