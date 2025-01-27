import * as React from "react";
import classNames from "classnames";
import { useRubric } from "./use-rubric";
import { ITagSummaryDisplay, tagSummaryDisplayLabels, tagSummaryDisplayValues } from "./types";

import "./rubric-general-options.scss";

type IRubricOptionKey = "criteriaLabel" | "criteriaLabelForStudent" | "feedbackLabelForStudent";
type IRubricOptionBooleanKey = "showRatingDescriptions" | "hideRubricFromStudentsInStudentReport";

export const RubricGeneralOptions = () => {
  const { rubric, setRubric } = useRubric();

  const handleUpdateString = (key: IRubricOptionKey) => (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setRubric(draft => {
      draft[key] = value;
    });
  };
  const handleUpdateCheckbox = (key: IRubricOptionBooleanKey) => (e: React.ChangeEvent<HTMLInputElement>) => {
    const checked = e.target.checked;
    setRubric(draft => {
      draft[key] = checked;
    });
  };
  const handleUpdateTagSummaryDisplay = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const tagSummaryDisplay = e.target.value as ITagSummaryDisplay;
    setRubric(draft => {
      draft.tagSummaryDisplay = tagSummaryDisplay;
    });
  };

  return (
    <div className="general-options">
      <table>
        <tbody>
          <tr>
            <td><label htmlFor="criteriaLabel">Criteria Header Label for Teacher:</label></td>
            <td><input name="criteriaLabel" type="text" value={rubric.criteriaLabel} onChange={handleUpdateString("criteriaLabel")} /></td>
          </tr>
          <tr>
            <td><label htmlFor="criteriaLabelForStudent">Criteria Header Label for Student:</label></td>
            <td>
              <input
                name="criteriaLabelForStudent"
                type="text"
                value={rubric.criteriaLabelForStudent}
                onChange={handleUpdateString("criteriaLabelForStudent")}
              />
            </td>
          </tr>
          <tr>
            <td><label htmlFor="feedbackLabelForStudent">Feedback Label for Student:</label></td>
            <td>
              <input
                name="feedbackLabelForStudent"
                type="text"
                value={rubric.feedbackLabelForStudent}
                onChange={handleUpdateString("feedbackLabelForStudent")}
              />
            </td>
          </tr>
          <tr>
            <td><label htmlFor="tagSummaryDisplay">Tag Summary Display:</label></td>
            <td>
              <select
                name="tagSummaryDisplay"
                value={rubric.tagSummaryDisplay}
                onChange={handleUpdateTagSummaryDisplay}
              >
                {tagSummaryDisplayValues.map(value => (
                  <option value={value} key={value}>{tagSummaryDisplayLabels[value]}</option>
                ))}
              </select>
            </td>
          </tr>
          <tr>
            <td/>
            <td className="rubric-checkbox">
              <input
                type="checkbox"
                name="hideRubricFromStudentsInStudentReport"
                checked={rubric.hideRubricFromStudentsInStudentReport}
                onChange={handleUpdateCheckbox("hideRubricFromStudentsInStudentReport")}
              />
              Hide rubric from students in Student Report
            </td>
          </tr>
          <tr>
            <td/>
            <td className="rubric-checkbox">
              <input
                type="checkbox"
                id="showRatingDescriptions"
                name="showRatingDescriptions"
                disabled={rubric.hideRubricFromStudentsInStudentReport}
                checked={rubric.showRatingDescriptions}
                onChange={handleUpdateCheckbox("showRatingDescriptions")}
              />
              <span
                id="showRatingDescriptionsLabel"
                className={classNames({disabled: rubric.hideRubricFromStudentsInStudentReport})}>
                Show rating descriptions
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  );
};
