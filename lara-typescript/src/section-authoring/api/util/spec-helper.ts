import { ISectionItem, ISection, IPage } from "../api-types";
import { collect } from "./array-util";

let pageCounter = 0;
let sectionCounter = 0;
let itemCounter = 0;

const makeItems = (count: number): ISectionItem[] => {
  return collect<ISectionItem>(count, () => ({ id: `item${itemCounter++}` }));
};

const makeSections = (count: number): ISection[] => {
  return collect<ISection>(count, () => {
    return { id: `section${sectionCounter++}`, items: makeItems(3) };
  });
};

export const makePages = (count: number): IPage[] => {
  return collect<IPage>(count, () => {
    return { id: `page${pageCounter++}`, sections: makeSections(3) };
  });
};