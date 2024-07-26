import * as React from "react";
import ReactMde from "react-mde";
import * as Showdown from "showdown";

import { IRubricCriterion, IRubricRating } from "./types";
import { Plus } from "./plus";
import { Trash } from "./trash";
import { useRubric } from "./use-rubric";

import "./rubric-criteria.scss";
import "react-mde/lib/styles/css/react-mde-all.css";

type CriterionKey = keyof IRubricCriterion;
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

export interface IRubricCriteriaItemItemProps {
  index: number;
  criterion: IRubricCriterion;
  onDelete: (index: number) => void;
}

export const RubricCriteriaItem = ({index, criterion, onDelete}: IRubricCriteriaItemItemProps) => {
  const {id} = criterion;
  const { rubric: { ratings }, setRubric } = useRubric();

  const handleDelete = () => onDelete(index);

  const handleCriteriaMarkdownUpdate = (key: CriterionKey) => (value: string) => {
    setRubric(prev => {
      const newCriteria = [...prev.criteria];
      newCriteria[index] = {...newCriteria[index], [key]: value};
      return {...prev, criteria: newCriteria};
    });
  };

  const handleRatingMarkdownUpdate = (rating: IRubricRating, key: CriterionRatingKey) => (value: string) => {
    setRubric(prev => {
      const newCriteria = [...prev.criteria];
      newCriteria[index] = {...newCriteria[index]};
      newCriteria[index][key][rating.id] = value;
      return {...prev, criteria: newCriteria};
    });
  };

  const handleNonApplicableRatingChange = (rating: IRubricRating) => (e: React.ChangeEvent<HTMLInputElement>) => {
    const checked = e.target.checked;
    setRubric(prev => {
      const newCriteria = [...prev.criteria];
      newCriteria[index] = {...newCriteria[index]};
      const {nonApplicableRatings} = newCriteria[index];
      const narIndex = nonApplicableRatings.indexOf(rating.id);
      if (checked && (narIndex === -1)) {
        nonApplicableRatings.push(rating.id);
      } else if (!checked && (narIndex !== -1)) {
        nonApplicableRatings.splice(narIndex, 1);
      }
      newCriteria[index].nonApplicableRatings = nonApplicableRatings;
      return {...prev, criteria: newCriteria};
    });
  };

  return (
    <div className="rubric-criteria-item">
      <div className="rubric-criteria-item-header">
        <div>Criterion: {id}</div>
        <button onClick={handleDelete}><Trash /> <span>Remove Criterion</span></button>
      </div>
      <div className="rubric-criteria-item-body">
        <div className="rubric-criteria-item-body-row">
          <div>
            <label htmlFor="description">{id} Teacher Description</label>
            <MarkdownEditor content={criterion.description} onChange={handleCriteriaMarkdownUpdate("description")} />
          </div>
          <div>
            <div className="rubric-criteria-item-body-row-label">
              <label htmlFor="descriptionForStudent">{id} Student Description</label>
              (Leave blank to use teacher description)
            </div>
            <MarkdownEditor content={criterion.descriptionForStudent} onChange={handleCriteriaMarkdownUpdate("descriptionForStudent")} />
          </div>
        </div>
        {ratings.length > 0 && (
          <>
            <div className="rubric-criteria-item-body-row">
              <div className="rubric-criteria-item-body-row-label" style={{flex: "initial"}}>
                <label htmlFor="description">Non-applicable Ratings for {id}:</label>
                <div className="rubric-checkboxes">{ratings.map(r => (
                  <div key={r.id}>
                    <input
                      type="checkbox"
                      checked={criterion.nonApplicableRatings.includes(r.id)}
                      onChange={handleNonApplicableRatingChange(r)}
                    /> {r.id} ({r.label})
                  </div>))}
                </div>
                <div>Note: A minimum of 2 ratings must be applicable.</div>
              </div>
            </div>
            <div className="rubric-criteria-item-body-row">
              <label>{id} Rating Descriptions</label>
            </div>
            {ratings.map(r => (
              <div className="rubric-criteria-item-body-row" key={r.id}>
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

export const RubricCriteria = () => {
  const { rubric, setRubric } = useRubric();

  const handleDelete = (index: number) => {
    if (confirm("Are you sure you want to delete this criterion?")) {
      setRubric(prev => {
        const next = [...prev.criteria];
        next.splice(index, 1);
        return {...prev, criteria: next};
      });
    }
  };

  const handleAdd = () => {
    setRubric(prev => {
      return {...prev, criteria: [...prev.criteria, {
        id: `C${prev.criteria.length + 1}`,
        description: "",
        descriptionForStudent: "",
        nonApplicableRatings: [],
        ratingDescriptions: {},
        ratingDescriptionsForStudent: {}
      }]};
    });
  };

  return (
    <div className="rubric-criteria">
      {rubric.criteria.map((criterion, index) => (
        <RubricCriteriaItem key={index} index={index} criterion={criterion} onDelete={handleDelete} />
      ))}
      <button onClick={handleAdd}><Plus /> <span>Add Criterion</span></button>
    </div>
  );
};
