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
  const { rubric, setRubric } = useRubric();

  if (!rubric) {
    return null;
  }

  const { ratings } = rubric;

  const handleDelete = (index: number) => {
    if (confirm("Are you sure you want to delete this rating?")) {
      setRubric(prev => {
        const ratingId = prev.ratings[index].id;
        const newRatings = [...prev.ratings];
        newRatings.splice(index, 1);
        const newCriteria = [...prev.criteria];
        newCriteria.forEach(c => {
          delete c.ratingDescriptions[ratingId];
          delete c.ratingDescriptionsForStudent[ratingId];
          c.nonApplicableRatings = c.nonApplicableRatings.filter(nar => nar !== ratingId);
        });
        return {...prev, ratings: newRatings, criteria: newCriteria};
      });
    }
  };

  const handleUpdate = (index: number, rating: IRubricRating) => {
    setRubric(prev => {
      const next = [...prev.ratings];
      next[index] = rating;
      return {...prev, ratings: next};
    });
  };

  const handleAdd = () => {
    setRubric(prev => {
      return {...prev, ratings: [...prev.ratings, {id: `R${prev.ratings.length + 1}`, label: "", score: 0}]};
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
