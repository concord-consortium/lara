import { ISection } from "../api/api-types";

export const sectionName = ({position, title, name}: Pick<ISection, "position" | "title" | "name">) => {
  return name || `Section ${position} ${title ? title : ""}`;
};

export const sectionNumber = ({position, name}: Pick<ISection, "position" | "name">) => {
  return name || position;
};
