import * as React from "react";

import { Plus } from "./plus";
import { Trash } from "./trash";
import { useRubric } from "./use-rubric";
import { RubricPanel } from "./rubric-panel";
import { RubricCriteriaGroup } from "./rubric-criteria-group";

import "./rubric-criteria.scss";

export const RubricCriteria = () => {
  const { rubric: { criteriaGroups }, setRubric } = useRubric();

  const handleAdd = () => {
    setRubric(draft => {
      draft.criteriaGroups.push({
        label: "",
        labelForStudent: "",
        criteria: [],
      });
    });
  };

  const handleDelete = (index: number) => (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (confirm("Are you sure you want to delete this criteria group?")) {
      setRubric(draft => {
        draft.criteriaGroups.splice(index, 1);
      });
    }
  };

  return (
    <div className="rubric-criteria">
      <h2>Criteria</h2>

      {criteriaGroups.map((criteriaGroup, index) => (
        <RubricPanel
          key={index}
          title={`Criteria Group: ${criteriaGroup.label.trim().length > 0 ? criteriaGroup.label : (index + 1)}`}
          button={<button onClick={handleDelete(index)}><Trash /> <span>Remove Criteria Group</span></button>}
        >
          <RubricCriteriaGroup criteriaGroup={criteriaGroup} groupIndex={index} />
        </RubricPanel>
      ))}

      <button onClick={handleAdd}><Plus /> <span>Add Criteria Group</span></button>
    </div>
  );
};
