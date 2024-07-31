import * as React from "react";
import Markdown from "markdown-to-jsx";
import ReactTooltip from "react-tooltip";
import { IRubric } from "./types";
import { LaunchIcon } from "./launch-icon";

import "./rubric-table.scss";

interface IProps {
  rubric: IRubric;
}

export const RubricTableContainer = ({rubric}: IProps) => {
  const { ratings, criteriaGroups, referenceURL } = rubric;

  const checkReferenceUrl = (e: React.MouseEvent<HTMLAnchorElement>) => {
    if (!/^https?/.test(referenceURL)) {
      if (referenceURL.trim().length > 0) {
        alert(`Invalid Scoring Guide URL: ${referenceURL.trim()}`);
      }
      e.preventDefault();
      e.stopPropagation();
      return;
    }
  };

  const renderColumnHeaders = () => {
    return (
      <div className="columnHeaders">
        <div className="rubricDescriptionHeader">
          <div className="scoringGuideArea">
            <a
              className="launchButton"
              href={referenceURL}
              target="_blank"
              data-cy="scoring-guide-launch-icon"
              onClick={checkReferenceUrl}
            >
              <LaunchIcon />
            </a>
            Scoring Guide
          </div>
          <div className="rubricDescriptionTitle">{rubric.criteriaLabel}</div>
        </div>
        {rubric.ratings.map((rating: any) =>
          <div className="rubricScoreHeader" key={rating.id}>
            <div className="rubricScoreLevel">{rating.label}</div>
            {rubric.scoreUsingPoints && <div className="rubricScoreNumber">({rating.score})</div>}
          </div>
        )}
      </div>
    );
  };

  const renderRatings = (crit: any) => {
    return (
      <div className="ratingsGroup">
        {ratings.map((rating: any, index: number) => renderStudentRating(crit, rating, index))}
      </div>
    );
  };

  const renderStudentRating = (crit: any, rating: any, buttonIndex: number) => {

    const critId = crit.id;
    const ratingId = rating.id;
    const radioButtonKey = `${critId}-${ratingId}`;
    // Tooltips displayed to teacher should actually show student description if it's available.
    const ratingDescription =
      (crit.ratingDescriptionsForStudent && crit.ratingDescriptionsForStudent[ratingId]) ||
      (crit.ratingDescriptions && crit.ratingDescriptions[ratingId]) ||
      "";
    const isApplicableRating = crit.nonApplicableRatings === undefined ||
      crit.nonApplicableRatings.indexOf(ratingId) < 0;
    const key = `${critId}-${ratingId}`;

    return (
      <div className="rubricScoreBox" key={radioButtonKey}>
        <div
          className="rubricButton"
          title={isApplicableRating ? undefined : "Not Applicable"}
          data-tip={true}
          data-for={key}>
          { !isApplicableRating
            ? <span className="noRating">N/A</span>
            : renderButton()
          }
        </div>
        {isApplicableRating &&
          <ReactTooltip
            id={key}
            place="left"
            type="dark"
            delayShow={500}>
            <Markdown>{ratingDescription}</Markdown>
          </ReactTooltip>}
      </div>
    );
  };

  const renderButton = () => {
    return (
      <button className="outerCircle" data-cy="rating-radio-button">
        <div className="innerCircle" />
      </button>
    );
  };

  return (
    <div className="rubricContainer" data-cy="rubric-table">
      {renderColumnHeaders()}
      <div className="rubricTable">
        {criteriaGroups.map((criteriaGroup, index) => (
          <div className="rubricTableGroup" key={index}>
            {criteriaGroup.label.length > 0 && <div className="rubricTableGroupLabel">{criteriaGroup.label}</div>}
            <div className="rubricTableRows">
              {criteriaGroup.criteria.map((crit) =>
                <div className="rubricTableRow" key={crit.id}>
                  <div className="rubricDescription">
                    {crit.iconUrl && <img src={crit.iconUrl} />}
                    <Markdown>{crit.description}</Markdown>
                  </div>
                  {renderRatings(crit)}
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
