import * as React from "react";
import { useState } from "react";
import { IRubricRating } from "./types";

import "./rubric-ratings.scss";

const Trash = ({onClick}: {onClick: () => void}) => {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" onClick={onClick}>
      <path d="M20 6h-3.155a.949.949 0 0 0-.064-.125l-1.7-2.124A1.989 1.989 0 0 0 13.519 3h-3.038a1.987 1.987 0 0 0-1.562.75l-1.7 2.125A.949.949 0 0 0 7.155 6H4a1 1 0 0 0 0 2h1v11a2 2 0 0 0 1.994 2h10.011A2 2 0 0 0 19 19V8h1a1 1 0 0 0 0-2zm-9.519-1h3.038l.8 1H9.681zm6.524 14H7V8h10z"/>
      <path d="M14 18a1 1 0 0 1-1-1v-7a1 1 0 0 1 2 0v7a1 1 0 0 1-1 1zM10 18a1 1 0 0 1-1-1v-7a1 1 0 0 1 2 0v7a1 1 0 0 1-1 1z"/>
    </svg>
  );
};

const Plus = () => {
  return (
    <svg viewBox="0 0 17 16" xmlns="http://www.w3.org/2000/svg" width="18" height="18">
      <path d="m9.021.097c-4.396 0-7.958 3.558-7.958 7.943 0 4.388 3.562 7.945 7.958 7.945 4.395 0 7.958-3.558 7.958-7.945 0-4.386-3.564-7.943-7.958-7.943zm2.304 8.985h-1.237v1.237c0 .979.059 1.769-1.088 1.769-1.144 0-1.088-.79-1.088-1.769v-1.237h-1.237c-.979 0-1.769.056-1.769-1.088 0-1.146.79-1.088 1.769-1.088h1.237v-1.237c0-.979-.056-1.769 1.088-1.769 1.146 0 1.088.79 1.088 1.769v1.237h1.237c.979 0 1.769-.059 1.769 1.088 0 1.144-.79 1.088-1.769 1.088z" fill="#434343" fill-rule="evenodd"/>
    </svg>
  );
};

export interface IRubricRatingsItemProps {
  index: number;
  rating: IRubricRating;
  onDelete: (index: number) => void;
}

export const RubricRatingsItem = ({index, rating, onDelete}: IRubricRatingsItemProps) => {
  const {id, label, score} = rating;
  const handleDelete = () => onDelete(index);

  return (
    <tr>
      <td><input name="rating[][id]" value={id} type="text" disabled={true} /></td>
      <td><input name="rating[][label]" defaultValue={label} type="text" autoFocus={true} /></td>
      <td><input name="rating[][score]" defaultValue={score} type="number" /></td>
      <td><Trash onClick={handleDelete} /></td>
    </tr>
  );
};

export interface IRatingsProps {
  ratings: IRubricRating[];
}

export const RubricRatings = (props: IRatingsProps) => {
  const [ratings, setRatings] = useState<IRubricRating[]>(props.ratings);

  const handleDelete = (index: number) => {
    if (confirm("Are you sure you want to delete this rating?")) {
      setRatings(prev => {
        const next = [...prev];
        next.splice(index, 1);
        return next;
      });
    }
  };

  const handleAdd = () => {
    setRatings(prev => {
      return [...prev, {id: `R${prev.length + 1}`, label: "", score: 0}];
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
            <RubricRatingsItem key={index} index={index} rating={rating} onDelete={handleDelete} />
          ))}
        </tbody>
      </table>}
      <button onClick={handleAdd}><Plus /> <span>Add Rating</span></button>
    </div>
  );
};
