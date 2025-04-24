import * as React from "react";
import Markdown from "markdown-to-jsx";
import { useRubric } from "./use-rubric";

import "./rubric-student-preview.scss";

interface IProps {
  scored: boolean;
  scoring: Record<string, string>;
  setScoring: React.Dispatch<React.SetStateAction<Record<string, string>>>;
}

const getStringValue = (value: string = "", fallbackValue: string = ""): string => {
  return value.trim().length > 0 ? value : fallbackValue;
};

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
      return acc || getStringValue(cur.labelForStudent, cur.label).trim().length > 0;
    }, false);
    const criteriaLabel = getStringValue(rubric.criteriaLabelForStudent, rubric.criteriaLabel);

    return (
      <div className="scored">
        <table>
          <thead>
            <tr>
              <th colSpan={hasGroupLabel ? 2 : 1}>
                { criteriaLabel }</th><th>{ rubric.feedbackLabelForStudent }
              </th>
            </tr>
          </thead>
          <tbody>
            {rubric.criteriaGroups.map((criteriaGroup) => {
              return criteriaGroup.criteria.map((criteria, index) => {
                const showLabel = index === 0 && hasGroupLabel;
                const ratingId = scoring[criteria.id];
                const label = getStringValue(
                  criteriaGroup.labelForStudent,
                  criteriaGroup.label
                );
                const description = getStringValue(
                  criteria.descriptionForStudent,
                  criteria.description
                );
                const ratingDescription = getStringValue(
                  criteria.ratingDescriptionsForStudent[ratingId],
                  criteria.ratingDescriptions[ratingId]
                );
                const rating = rubric.ratings.find(r => r.id === ratingId);
                const ratingLabel = rating?.label.toUpperCase() ?? "";

                return (
                  <tr key={criteria.id}>
                    {showLabel &&
                      <td
                        rowSpan={criteriaGroup.criteria.length}
                        className="groupLabel">
                        {label}
                      </td>
                    }
                    <td>
                      <div>
                        {criteria.iconUrl && <img src={criteria.iconUrl} title={criteria.iconPhrase} />}
                        <Markdown>{description}</Markdown>
                      </div>
                    </td>
                    <td>
                      { rubric.showRatingDescriptions
                        ? `${ratingLabel} – ${ratingDescription}`
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
    <div className="rubricStudentPreview" data-testid="rubric-student-preview">
      {hide ? renderHidden() : (scored ? renderScored() : renderUnscored())}
    </div>
  );

};
