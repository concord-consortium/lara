import * as React from "react";
import Markdown from "markdown-to-jsx";
import ReactTooltip from "react-tooltip";
import classNames from "classnames";

import { LaunchIcon } from "./launch-icon";
import { useRubric } from "./use-rubric";
import { IRubricCriterion, IRubricRating } from "./types";

import "./rubric-teacher-preview.scss";
import { useMemo } from "react";

interface IProps {
  scoring: Record<string, string>;
  setScoring: React.Dispatch<React.SetStateAction<Record<string, string>>>;
  referenceURL: string;
}

export const RubricTeacherPreview = ({scoring, setScoring, referenceURL}: IProps) => {
  const { rubric } = useRubric();
  const { ratings, criteriaGroups } = rubric;

  const hasReferenceUrl = useMemo(() => referenceURL.trim().length > 0, [referenceURL]);

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
          {hasReferenceUrl && <div className="scoringGuideArea">
            <a
              className="launchButton"
              href={referenceURL}
              target="_blank"
              data-testid="scoring-guide-launch-icon"
              onClick={checkReferenceUrl}
            >
              <LaunchIcon />
            </a>
            Scoring Guide
          </div>}
          <div className="rubricDescriptionTitle">{rubric.criteriaLabel}</div>
        </div>
        {rubric.ratings.map((rating: any) =>
          <div className="rubricScoreHeader" key={rating.id}>
            <div className="rubricScoreLevel">{rating.label}</div>
            <div className="rubricScoreNumber">({rating.score})</div>
          </div>
        )}
      </div>
    );
  };

  const renderRatings = (crit: IRubricCriterion) => {
    return (
      <div className="ratingsGroup">
        {ratings.map((rating) => renderStudentRating(crit, rating))}
      </div>
    );
  };

  const renderStudentRating = (crit: IRubricCriterion, rating: IRubricRating) => {

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
            : renderButton(crit, rating)
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

  const renderButton = (crit: IRubricCriterion, rating: IRubricRating) => {
    const selected = scoring[crit.id] === rating.id;
    const handleClick = () => setScoring(prev => (
      {...prev, [crit.id]: rating.id}
    ));

    return (
      <button
        className={classNames("outerCircle", {selected})}
        data-testid="rating-radio-button"
        onClick={handleClick}
      />
    );
  };

  return (
    <div className="rubricTeacherPreview" data-testid="rubric-teacher-preview">
      {renderColumnHeaders()}
      <div className="rubricTable">
        {criteriaGroups.map((criteriaGroup, index) => (
          <div className="rubricTableGroup" key={index}>
            {criteriaGroup.label.length > 0 && <div className="rubricTableGroupLabel">{criteriaGroup.label}</div>}
            <div className="rubricTableRows">
              {criteriaGroup.criteria.map((crit) =>
                <div className="rubricTableRow" key={crit.id}>
                  <div className="rubricDescription">
                    {crit.iconUrl && <img src={crit.iconUrl} title={crit.iconPhrase} />}
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
