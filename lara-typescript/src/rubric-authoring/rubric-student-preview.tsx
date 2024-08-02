import * as React from "react";
import Markdown from "markdown-to-jsx";
import { useRubric } from "./use-rubric";

import "./rubric-student-preview.scss";

interface IProps {
  scored: boolean;
  scoring: Record<string, string>;
  setScoring: React.Dispatch<React.SetStateAction<Record<string, string>>>;
}

export const RubricStudentPreview = ({scored, scoring, setScoring}: IProps) => {
  const { rubric } = useRubric();
  const hide = rubric.hideRubricFromStudentsInStudentReport;

  const renderHidden = () => {
    return (
      <div className="hidden">
        The "Hide rubric from students in Student Report" option is selected.
        Students will not see or get feedback from the rubric on their reports.
      </div>
    );
  };

  const renderUnscored = () => {
    return (
      <div className="unscored">
        Please fully score the rubric in the teacher view first.
      </div>
    );
  };

  const renderScored = () => {
    const hasGroupLabel = rubric.criteriaGroups.reduce((acc, cur) => {
      return acc || cur.labelForStudent.trim().length > 0;
    }, false);

    return (
      <div className="scored">
        <table>
          <thead>
            <tr>
              <th colSpan={hasGroupLabel ? 2 : 1}>
                { rubric.criteriaLabelForStudent }</th><th>{ rubric.feedbackLabelForStudent }
              </th>
            </tr>
          </thead>
          <tbody>
            {rubric.criteriaGroups.map((criteriaGroup) => {
              return criteriaGroup.criteria.map((criteria, index) => {
                const showLabel = index === 0 && hasGroupLabel;
                const ratingId = scoring[criteria.id];
                const description = criteria.ratingDescriptionsForStudent[ratingId];
                const rating = rubric.ratings.find(r => r.id === ratingId);
                const ratingLabel = rating?.label.toUpperCase() ?? "";

                return (
                  <tr key={criteria.id}>
                    {showLabel && <td rowSpan={criteriaGroup.criteria.length}>{criteriaGroup.labelForStudent}</td>}
                    <td>
                      <div>
                        {criteria.iconUrl && <img src={criteria.iconUrl} />}
                        <Markdown>{criteria.descriptionForStudent}</Markdown>
                      </div>
                    </td>
                    <td>
                      { rubric.showRatingDescriptions
                        ? `${ratingLabel} – ${description}`
                        : ratingLabel
                      }
                    </td>
                  </tr>
                );
              });
            })}
          </tbody>
        </table>
      </div>
    );
  };

  return (
    <div className="rubricStudentPreview" data-cy="rubric-student-preview">
      {hide ? renderHidden() : (scored ? renderScored() : renderUnscored())}
    </div>
  );

};
