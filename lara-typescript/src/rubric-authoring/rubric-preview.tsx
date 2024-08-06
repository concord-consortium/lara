import * as React from "react";
import { useMemo, useState } from "react";
import classNames from "classnames";

import { useRubric } from "./use-rubric";
import { RubricTeacherPreview } from "./rubric-teacher-preview";
import { RubricStudentPreview } from "./rubric-student-preview";

import "./rubric-preview.scss";

interface IProps {
  referenceURL: string;
}

export const RubricPreview = ({referenceURL}: IProps) => {
  const { rubric } = useRubric();
  const [view, setView] = useState<"teacher"|"student">("teacher");
  const [scoring, setScoring] = useState<Record<string, string>>({});

  const scored = useMemo(() => {
    const criteriaIds = rubric.criteriaGroups.reduce<string[]>((acc, cur) => {
      return cur.criteria.reduce((acc2, cur2) => {
        acc2.push(cur2.id);
        return acc2;
      }, acc);
    }, []);
    if (criteriaIds.length === 0) {
      return false;
    }
    return criteriaIds.reduce((acc, cur) => {
      return acc && !!scoring[cur];
    }, true);
  }, [rubric, scoring]);

  const handleSetTeacherView = () => setView("teacher");
  const handleSetStudentView = () => setView("student");

  return (
    <div className="rubricPreview" data-cy="rubric-preview">
      <div className="rubricPreviewSwitcher">
        <div
          className={classNames({rubricPreviewActive: view === "teacher"})}
          onClick={handleSetTeacherView}>
          Teacher View
        </div>
        <div
          className={classNames({rubricPreviewActive: view === "student"})}
          onClick={handleSetStudentView}>
          Student View
        </div>
      </div>
      {view === "teacher" &&
        <RubricTeacherPreview scoring={scoring} setScoring={setScoring} referenceURL={referenceURL} />
      }
      {view === "student" &&
        <RubricStudentPreview scored={scored} scoring={scoring} setScoring={setScoring} />
      }
    </div>
  );
};
