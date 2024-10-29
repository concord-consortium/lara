import { useEffect, useState, useRef } from "react";

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
  hide_question_number: boolean;
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
  customizable: boolean;
  authorable: boolean;
  report_item_url: string;
}

interface ILoadingState {
  state: "loading";
}
interface IErrorState {
  state: "error";
  error: string;
}
interface ILoadedState {
  state: "loaded";
  list: ILibraryInteractive[];
}
type UseLibraryInteractiveState = ILoadingState | IErrorState | ILoadedState;

export const useLibraryInteractives = () => {
  const [state, setState] = useState<UseLibraryInteractiveState>({state: "loading"});

  // load the list of interactives once at load time - this json is readable by admins and authors
  useEffect(() => {
    $.getJSON("/library_interactives")
    .done((list: ILibraryInteractive[]) => {
      setState({ state: "loaded", list });
    })
    .fail((jqxhr, textStatus, error) => {
      setState({ state: "error", error: error.toString() });
    });
  }, []);

  return state;
};
