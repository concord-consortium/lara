import * as React from "react";
import { useState } from "react";

export type QuestionGating = "none" | "disable_following_on_page" | "disable_following_in_section";

const TWO_COLUMN_HINT = "In a two-column section, every question in the other column counts as after this " +
  "interactive, so put a question that should stay open in a separate section.";
const SUPPORT_HINT = "The interactive must support unlocking questions.";

export const QUESTION_GATING_OPTIONS: Array<{ value: QuestionGating, label: string, hint: string }> = [
  {
    value: "none",
    label: "No questions",
    hint: "No questions are locked. Choose another option to lock the questions after this interactive in the " +
      `Activity Player until it unlocks them. ${SUPPORT_HINT}`
  },
  {
    value: "disable_following_on_page",
    label: "All questions after this on the page",
    hint: "In the Activity Player, every question after this interactive on the page, including those in later " +
      `sections, starts locked until this interactive unlocks them. ${TWO_COLUMN_HINT} ${SUPPORT_HINT}`
  },
  {
    value: "disable_following_in_section",
    label: "Only questions after this in this section",
    hint: "In the Activity Player, the questions after this interactive in this section start locked until it " +
      `unlocks them, and later sections stay open. ${TWO_COLUMN_HINT} ${SUPPORT_HINT}`
  }
];

interface Props {
  questionGating?: string | null;
  lockedText?: string | null;
  unlockedText?: string | null;
}

export const QuestionGatingOptions: React.FC<Props> = ({ questionGating, lockedText, unlockedText }) => {
  const [gating, setGating] = useState(questionGating || "none");
  const handleChange = (e: React.ChangeEvent<HTMLSelectElement>) => setGating(e.target.value);

  return (
    <fieldset>
      <legend>Question Gating</legend>
      <label htmlFor="question_gating">Locked until this interactive unlocks them</label>
      <select id="question_gating" name="question_gating" value={gating} onChange={handleChange}
        aria-describedby="question_gating_note">
        {QUESTION_GATING_OPTIONS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
      </select>
      <div id="question_gating_note" className="warning">
        {(QUESTION_GATING_OPTIONS.find(o => o.value === gating) ?? QUESTION_GATING_OPTIONS[0]).hint}
      </div>
      {gating !== "none" && <>
        <div className="question-gating-text">
          <label htmlFor="question_gating_locked_text">Locked banner text</label>
          <input type="text" id="question_gating_locked_text" name="question_gating_locked_text"
            defaultValue={lockedText || ""} aria-describedby="question_gating_text_note" />
        </div>
        <div className="question-gating-text">
          <label htmlFor="question_gating_unlocked_text">Unlocked banner text</label>
          <input type="text" id="question_gating_unlocked_text" name="question_gating_unlocked_text"
            defaultValue={unlockedText || ""} aria-describedby="question_gating_text_note" />
        </div>
        <div id="question_gating_text_note" className="warning">
          Leave a banner text blank to use the Activity Player's default.
        </div>
      </>}
    </fieldset>
  );
};
