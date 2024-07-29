import * as React from "react";
import { useCallback } from "react";

import { IRubricRating } from "./types";
import { Trash } from "./trash";
import { Plus } from "./plus";
import { useRubric } from "./use-rubric";

import "./rubric-ratings.scss";

export interface IRubricRatingsItemProps {
  index: number;
  rating: IRubricRating;
  onDelete: (index: number) => void;
  onUpdate: (index: number, rating: IRubricRating) => void;
}

export const RubricRatingsItem = ({index, rating, onDelete, onUpdate}: IRubricRatingsItemProps) => {
  const {id, label, score} = rating;

  const handleDelete = () => onDelete(index);
  const handleLabelUpdate = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    onUpdate(index, {...rating, label: e.target.value});
  }, [rating]);
  const handleScoreUpdate = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    onUpdate(index, {...rating, score: parseInt(e.target.value, 10)});
  }, [rating]);

  return (
    <tr>
      <td><input value={id} type="text" disabled={true} /></td>
      <td><input value={label} type="text" autoFocus={true} onChange={handleLabelUpdate} /></td>
      <td><input value={score} type="number" onChange={handleScoreUpdate} /></td>
      <td><Trash onClick={handleDelete} /></td>
    </tr>
  );
};

export const RubricRatings = () => {
  const { rubric: { ratings }, setRubric } = useRubric();

  const handleDelete = (index: number) => {
    if (confirm("Are you sure you want to delete this rating?")) {
      setRubric(draft => {
        const ratingId = draft.ratings[index].id;
        draft.ratings.splice(index, 1);
        draft.criteriaGroups.forEach(group => {
          group.criteria.forEach(criterion => {
            delete criterion.ratingDescriptions[ratingId];
            delete criterion.ratingDescriptionsForStudent[ratingId];
            criterion.nonApplicableRatings = criterion.nonApplicableRatings.filter(nar => nar !== ratingId);
          });
        });
      });
    }
  };

  const handleUpdate = (index: number, rating: IRubricRating) => {
    setRubric(draft => {
      draft.ratings[index] = rating;
    });
  };

  const handleAdd = () => {
    setRubric(draft => {
      draft.ratings.push({id: `R${draft.ratings.length + 1}`, label: "", score: 0});
    });
  };

  return (
    <div className="rubric-ratings">
      {ratings.length > 0 && <table>
        <thead>
          <tr>
            <th>Rating ID</th>
            <th>Rating Label</th>
            <th>Rating Score</th>
            <th />
          </tr>
        </thead>
        <tbody>
          {ratings.map((rating, index) => (
            <RubricRatingsItem
              key={index}
              index={index}
              rating={rating}
              onDelete={handleDelete}
              onUpdate={handleUpdate}
            />
          ))}
        </tbody>
      </table>}
      <button onClick={handleAdd}><Plus /> <span>Add Rating</span></button>
    </div>
  );
};
