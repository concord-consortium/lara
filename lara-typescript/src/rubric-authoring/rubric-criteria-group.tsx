import * as React from "react";

import { Plus } from "./plus";
import { useRubric } from "./use-rubric";
import { IRubricCriteriaGroup } from "./types";
import { RubricCriterion } from "./rubric-criterion";

import "./rubric-criteria-group.scss";

interface IRubricCriteriaGroupProps {
  groupIndex: number;
  criteriaGroup: IRubricCriteriaGroup;
}

export const RubricCriteriaGroup = ({criteriaGroup, groupIndex}: IRubricCriteriaGroupProps) => {
  const { setRubric } = useRubric();

  const handleDelete = (index: number) => {
    if (confirm("Are you sure you want to delete this criterion?")) {
      setRubric(draft => {
        draft.criteriaGroups[groupIndex].criteria.splice(index, 1);
      });
    }
  };

  const handleAdd = () => {
    setRubric(draft => {
      draft.criteriaGroups[groupIndex].criteria.push({
        id: `${groupIndex}_C${draft.criteriaGroups[groupIndex].criteria.length + 1}`,
        description: "",
        descriptionForStudent: "",
        nonApplicableRatings: [],
        ratingDescriptions: {},
        ratingDescriptionsForStudent: {},
        iconUrl: "",
        iconPhrase: "",
      });
    });
  };

  const handleLabelChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const label = e.target.value;
    setRubric(draft => {
      draft.criteriaGroups[groupIndex].label = label;
    });
  };

  const handleLabelForStudentChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const labelForStudent = e.target.value;
    setRubric(draft => {
      draft.criteriaGroups[groupIndex].labelForStudent = labelForStudent;
    });
  };

  return (
    <div className="rubric-criteria-group">
      <div className="rubric-criteria-group-input">
        <label>Criteria Group Label for Teacher (optional):</label>
        <input type="text" value={criteriaGroup.label} onChange={handleLabelChange} />
      </div>
      <div className="rubric-criteria-group-input">
        <label>Criteria Group Label for Student (optional):</label>
        <input type="text" value={criteriaGroup.labelForStudent} onChange={handleLabelForStudentChange} />
      </div>
      {criteriaGroup.criteria.map((criterion, index) => (
        <RubricCriterion
          key={index}
          index={index}
          groupIndex={groupIndex}
          criterion={criterion}
          onDelete={handleDelete}
        />
      ))}
      <button onClick={handleAdd}><Plus /> <span>Add Criterion</span></button>
    </div>
  );
};
