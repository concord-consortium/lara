import * as React from "react";
import { useRubric } from "./use-rubric";
import { IRubric } from "./types";

import "./rubric-general-options.scss";

type IRubricOptions = Omit<IRubric, "ratings" | "criteria">;
type IRubricOptionKey = keyof IRubricOptions;
type IRubricOptionBooleanKey = "showRatingDescriptions" | "scoreUsingPoints" | "hideRubricFromStudentsInStudentReport";

export const RubricGeneralOptions = () => {
  const { rubric, setRubric } = useRubric();

  if (!rubric) {
    return null;
  }

  const handleUpdateString = (key: IRubricOptionKey) => (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setRubric(prev => {
      return {...prev, [key]: value};
    });
  };
  const handleUpdateCheckbox = (key: IRubricOptionBooleanKey) => (e: React.ChangeEvent<HTMLInputElement>) => {
    const checked = e.target.checked;
    setRubric(prev => {
      return {...prev, [key]: checked};
    });
  };

  return (
    <div className="general-options">
      <table>
        <tbody>
          <tr>
            <td><label htmlFor="id">ID:</label></td>
            <td><input name="id" type="text" disabled={true} /></td>
          </tr>
          <tr>
            <td><label htmlFor="referenceURL">Reference URL (Scoring Guide):</label></td>
            <td><input name="referenceURL" type="text" onChange={handleUpdateString("referenceURL")} /></td>
          </tr>
          <tr>
            <td><label htmlFor="criteriaLabel">Criteria Header Label for Teacher:</label></td>
            <td><input name="criteriaLabel" type="text" onChange={handleUpdateString("criteriaLabel")} /></td>
          </tr>
          <tr>
            <td><label htmlFor="criteriaLabelForStudent">Criteria Header Label for Student:</label></td>
            <td>
              <input
                name="criteriaLabelForStudent"
                type="text"
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
                onChange={handleUpdateString("feedbackLabelForStudent")}
              />
            </td>
          </tr>
          <tr>
            <td/>
            <td className="rubric-checkbox">
              <input
                type="checkbox"
                name="showRatingDescriptions"
                value="true"
                onChange={handleUpdateCheckbox("showRatingDescriptions")}
              /> Show rating descriptions
            </td>
          </tr>
          <tr>
            <td/>
            <td className="rubric-checkbox">
              <input
                type="checkbox"
                name="scoreUsingPoints"
                value="true"
                onChange={handleUpdateCheckbox("scoreUsingPoints")}
              /> Score using points
            </td>
          </tr>
          <tr>
            <td/>
            <td className="rubric-checkbox">
              <input
                type="checkbox"
                name="hideRubricFromStudentsInStudentReport"
                value="true"
                onChange={handleUpdateCheckbox("hideRubricFromStudentsInStudentReport")}
              />
              Hide rubric from students in Student Report
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  );
};
