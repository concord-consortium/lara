import * as React from "react";

import "./rubric-general-options.scss";

export interface IGeneralOptionsProps {
}

export const RubricGeneralOptions = (props: IGeneralOptionsProps) => {
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
            <td><input name="referenceURL" type="text" /></td>
          </tr>
          <tr>
            <td><label htmlFor="criteriaLabel">Criteria Header Label for Teacher:</label></td>
            <td><input name="criteriaLabel" type="text" /></td>
          </tr>
          <tr>
            <td><label htmlFor="criteriaLabelForStudent">Criteria Header Label for Student:</label></td>
            <td><input name="criteriaLabelForStudent" type="text" /></td>
          </tr>
          <tr>
            <td><label htmlFor="feedbackLabelForStudent">Feedback Label for Student:</label></td>
            <td><input name="feedbackLabelForStudent" type="text" /></td>
          </tr>
          <tr>
            <td/>
            <td className="rubric-checkbox">
              <input type="checkbox" name="showRatingDescriptions" value="true" /> Show rating descriptions
            </td>
          </tr>
          <tr>
            <td/>
            <td className="rubric-checkbox">
              <input type="checkbox" name="scoreUsingPoints" value="true" /> Score using points
            </td>
          </tr>
          <tr>
            <td/>
            <td className="rubric-checkbox">
              <input type="checkbox" name="hideRubricFromStudentsInStudentReport" value="true" />
              Hide rubric from students in Student Report
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  );
};
