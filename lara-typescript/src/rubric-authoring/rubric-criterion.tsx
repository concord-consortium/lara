import * as React from "react";
import ReactMde from "react-mde";
import * as Showdown from "showdown";

import { IRubricCriterion, IRubricRating } from "./types";
import { Trash } from "./trash";
import { useRubric } from "./use-rubric";

import "./rubric-criterion.scss";
import "react-mde/lib/styles/css/react-mde-all.css";

type CriterionKey =  "description" | "descriptionForStudent";
type CriterionRatingKey = "ratingDescriptions" | "ratingDescriptionsForStudent";

const converter = new Showdown.Converter({
  tables: true,
  simplifiedAutoLink: true,
  strikethrough: true,
  tasklists: true
});

const MarkdownEditor = ({content, onChange}: {content: string, onChange: (value: string) => void}) => {
  const [selectedTab, setSelectedTab] = React.useState<"write" | "preview">("write");

  const handleGenerateMarkdown = (markdown: string) => Promise.resolve(converter.makeHtml(markdown));

  return (
    <ReactMde
      value={content}
      onChange={onChange}
      selectedTab={selectedTab}
      onTabChange={setSelectedTab}
      generateMarkdownPreview={handleGenerateMarkdown}
    />
  );
};

export interface RubricCriterionProps {
  index: number;
  groupIndex: number;
  criterion: IRubricCriterion;
  onDelete: (index: number) => void;
}

export const RubricCriterion = ({index, groupIndex, criterion, onDelete}: RubricCriterionProps) => {
  // remove group index from id
  const displayId = criterion.id.includes("_") ? criterion.id.split("_")[1] : criterion.id;
  const { rubric: { ratings }, setRubric } = useRubric();
  const isNonApplicableRating = (rating: IRubricRating) => criterion.nonApplicableRatings.includes(rating.id);
  const applicableRatings = ratings.filter(r => !isNonApplicableRating(r));

  const handleDelete = () => onDelete(index);

  const handleIconUrlChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const url = e.target.value;
    setRubric(draft => {
      draft.criteriaGroups[groupIndex].criteria[index].iconUrl = url;
    });
  };

  const handleIconPhraseChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const phrase = e.target.value;
    setRubric(draft => {
      draft.criteriaGroups[groupIndex].criteria[index].iconPhrase = phrase;
    });
  };

  const handleCriteriaMarkdownUpdate = (key: CriterionKey) => (value: string) => {
    setRubric(draft => {
      draft.criteriaGroups[groupIndex].criteria[index][key] = value;
    });
  };

  const handleRatingMarkdownUpdate = (rating: IRubricRating, key: CriterionRatingKey) => (value: string) => {
    setRubric(draft => {
      draft.criteriaGroups[groupIndex].criteria[index][key][rating.id] = value;
    });
  };

  const handleNonApplicableRatingChange = (rating: IRubricRating) => (e: React.ChangeEvent<HTMLInputElement>) => {
    const checked = e.target.checked;
    setRubric(draft => {
      const {nonApplicableRatings} = draft.criteriaGroups[groupIndex].criteria[index];
      const narIndex = nonApplicableRatings.indexOf(rating.id);
      if (checked && (narIndex === -1)) {
        nonApplicableRatings.push(rating.id);
      } else if (!checked && (narIndex !== -1)) {
        nonApplicableRatings.splice(narIndex, 1);
      }
    });
  };

  return (
    <div className="rubric-criterion">
      <div className="rubric-criterion-header">
        <div>Criterion: {displayId}</div>
        <button onClick={handleDelete}><Trash /> <span>Remove Criterion</span></button>
      </div>
      <div className="rubric-criterion-body">
        <div className="rubric-criterion-body-row">
          <div>
            <div className="rubric-criterion-body-row-label" style={{flex: "initial"}}>
              <label htmlFor="iconUrl">Tag Icon URL:</label>
              <input
                type="text"
                value={criterion.iconUrl}
                onChange={handleIconUrlChange}
              />
            </div>
          </div>
          <div>
            <div className="rubric-criterion-body-row-label" style={{flex: "initial"}}>
              <label htmlFor="iconPhrase">Tag Icon Phrase:</label>
              <input
                type="text"
                value={criterion.iconPhrase}
                onChange={handleIconPhraseChange}
              />
            </div>
          </div>
        </div>

        <div className="rubric-criterion-body-row">
          <div>
            <label htmlFor="description">{displayId} Teacher Description</label>
            <MarkdownEditor content={criterion.description} onChange={handleCriteriaMarkdownUpdate("description")} />
          </div>
          <div>
            <div className="rubric-criterion-body-row-label">
              <label htmlFor="descriptionForStudent">{displayId} Student Description</label>
              (Leave blank to use teacher description)
            </div>
            <MarkdownEditor content={criterion.descriptionForStudent} onChange={handleCriteriaMarkdownUpdate("descriptionForStudent")} />
          </div>
        </div>
        {ratings.length > 0 && (
          <>
            <div className="rubric-criterion-body-row">
              <div className="rubric-criterion-body-row-label" style={{flex: "initial"}}>
                <label htmlFor="description">Non-applicable Ratings for {displayId}:</label>
                <div className="rubric-checkboxes">{ratings.map(r => (
                  <div key={r.id}>
                    <input
                      type="checkbox"
                      checked={isNonApplicableRating(r)}
                      onChange={handleNonApplicableRatingChange(r)}
                    /> {r.id} ({r.label})
                  </div>))}
                </div>
                <div>Note: A minimum of 2 ratings must be applicable.</div>
              </div>
            </div>
            <div className="rubric-criterion-body-row">
              <label>{displayId} Rating Descriptions</label>
            </div>
            {applicableRatings.map(r => (
              <div className="rubric-criterion-body-row" key={r.id}>
                <div>
                  <label htmlFor="description">{r.id} ({r.label}) Teacher Description</label>
                  <MarkdownEditor
                    content={criterion.ratingDescriptions[r.id]}
                    onChange={handleRatingMarkdownUpdate(r, "ratingDescriptions")}
                  />
                </div>
                <div>
                  <label htmlFor="description">{r.id} ({r.label}) Student Description</label>
                  <MarkdownEditor
                    content={criterion.ratingDescriptionsForStudent[r.id]}
                    onChange={handleRatingMarkdownUpdate(r, "ratingDescriptionsForStudent")}
                  />
                </div>
              </div>
            ))}
          </>
        )}
      </div>
    </div>
  );
};
