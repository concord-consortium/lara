import * as React from "react";
import { useState } from "react";

export type QuestionGating = "none" | "disable_following_on_page" | "disable_following_in_section";

export const QUESTION_GATING_OPTIONS: Array<{ value: QuestionGating, label: string }> = [
  { value: "none", label: "None" },
  { value: "disable_following_on_page", label: "All questions after this on the page" },
  { value: "disable_following_in_section", label: "Only questions after this in this section" }
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
      <div id="question_gating_note" className="inputNote">
        In the Activity Player, the chosen questions start locked until this interactive unlocks them.
        In a two-column section, every question in the other column counts as after this interactive,
        so put a question that should stay open in a separate section. The interactive must support
        unlocking questions.
      </div>
      {gating !== "none" && <>
        <label htmlFor="question_gating_locked_text">Locked banner text</label>
        <input type="text" id="question_gating_locked_text" name="question_gating_locked_text"
          defaultValue={lockedText || ""} aria-describedby="question_gating_text_note" />
        <label htmlFor="question_gating_unlocked_text">Unlocked banner text</label>
        <input type="text" id="question_gating_unlocked_text" name="question_gating_unlocked_text"
          defaultValue={unlockedText || ""} aria-describedby="question_gating_text_note" />
        <div id="question_gating_text_note" className="inputNote">
          Leave a banner text blank to use the Activity Player's default.
        </div>
      </>}
    </fieldset>
  );
};
