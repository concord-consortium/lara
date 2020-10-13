// Each time these interfaces are updated, it might be necessary to also update base_interactive.rb
// and interactive_run_state.rb files that process this data passed from interactives and send
// to report service and portal.

// Authoring metadata:

export type ChoiceId = string;

export interface IAuthoringMetadataBase {
  questionType: string;
  /**
   * Interactive can optionally set questionSubType, so Teacher Report can display different icons
   * or categorize interactives into subcategories.
   */
  questionSubType?: string;
  required?: boolean;
  prompt?: string;
}

/**
 * Generic interactive type.
 */
export interface IAuthoringInteractiveMetadata extends IAuthoringMetadataBase {
  questionType: "iframe_interactive";
}

export interface IAuthoringOpenResponseMetadata extends IAuthoringMetadataBase {
  questionType: "open_response";
}

export interface IAuthoringMultipleChoiceChoiceMetadata {
  id: ChoiceId;
  content?: string;
  correct?: boolean;
}

export interface IAuthoringMultipleChoiceMetadata extends IAuthoringMetadataBase {
  questionType: "multiple_choice";
  choices: IAuthoringMultipleChoiceChoiceMetadata[];
}

export interface IAuthoringImageQuestionMetadata extends IAuthoringMetadataBase {
  questionType: "image_question";
  answerPrompt?: string;
}

export type IAuthoringMetadata = IAuthoringInteractiveMetadata | IAuthoringOpenResponseMetadata |
  IAuthoringMultipleChoiceMetadata | IAuthoringImageQuestionMetadata;

// Runtime metadata:

export interface IRuntimeMetadataBase {
  answerType: string;
  submitted?: boolean;
  /**
   * answerText can be used by all the interactive types to display answer summary without having to load iframe
   * with report view.
   */
  answerText?: string;
}

export interface IRuntimeInteractiveMetadata extends IRuntimeMetadataBase {
  answerType: "interactive_state";
}

export interface IRuntimeOpenResponseMetadata extends IRuntimeMetadataBase {
  /**
   * answerType is different so Report and Portal can recognize this type of question.
   * Use answerText (defined in IRuntimeMetadataBase) to provide open response answer.
   */
  answerType: "open_response_answer";
}

export interface IRuntimeMultipleChoiceMetadata extends IRuntimeMetadataBase {
  answerType: "multiple_choice_answer";
  selectedChoiceIds: ChoiceId[];
}

export interface IRuntimeImageQuestionMetadata extends IRuntimeMetadataBase {
  answerType: "image_question_answer";
  answerImageUrl?: string;
}

export type IRuntimeMetadata = IRuntimeInteractiveMetadata | IRuntimeOpenResponseMetadata |
  IRuntimeMultipleChoiceMetadata | IRuntimeImageQuestionMetadata;
