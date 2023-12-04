import * as React from "react";

import "./project-list-item.scss";

export interface IProjectListItemProps {
  id?: number;
  title: string;
  url: string | undefined;
  onDelete?: (id: number) => void;
}

export const ProjectListItem: React.FC<IProjectListItemProps> = ({
  id,
  title,
  url,
  onDelete
  }: IProjectListItemProps ) => {

  const handleEditButtonClick = () => {
    window.location.href = `/projects/${id}/edit`;
  };

  const handleDeleteButtonClick = () => {
    if (id) {
      onDelete?.(id);
    }
  };

  return(
    <li className="projectListItem">
      <div className="projectListItem__title" onClick={handleEditButtonClick}>{title}</div>
      <menu>
        <ul>
          <li><button className="textButton editButton" onClick={handleEditButtonClick}>Edit</button></li>
          {onDelete && <li><button className="textButton deleteButton" onClick={handleDeleteButtonClick}>Delete</button></li>}
        </ul>
      </menu>
      <div className="projectListItem__link">
        Links to <a className="projectLink" href="{url}" target="_blank">{url}</a>
      </div>
    </li>
  );
};
