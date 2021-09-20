import * as React from "react";
import { AuthoringSection, ISectionProps } from "./authoring-section";
import { DragDropContext, Droppable, Draggable, DropResult } from "react-beautiful-dnd";
import { ISectionItem } from "./section-item-picker";
import { ICreatePageItem } from "./query-bound-page";

import "./authoring-page.css";

export interface IPageProps {

  /**
   * Record ID
   */
  id: string;

  /**
   * Optional title for the page
   */
  title?: string;

  /**
   * Sections on this page:
   */
  sections: ISectionProps[];

  /**
   * Is page a completion page?
   */
  is_completion: boolean;

  /**
   * how to add a new section
   */
  addSection?: () => void;

  /**
   *
   */
  changeSection?: (changes: {section: Partial<ISectionProps>, sectionID: string}) => void;

  /*
   * Call back to invoke when sections have been rearranged or deleted
   */
  setSections?: (pageData: IPageProps) => void;

  /*
   * List of all section items available
   */
  allSectionItems?: ISectionItem[];

  /**
   * how to add a new page item
   */
   addPageItem?: (pageItem: ICreatePageItem) => void;
}

/**
 * Primary UI component for user interaction
 */
export const AuthoringPage: React.FC<IPageProps> = ({
  id,
  title,
  sections = [],
  addSection,
  changeSection,
  setSections,
  allSectionItems,
  addPageItem
  }: IPageProps) => {

  /*
   * Return a new array with array[a] and array[b] swapped.
   */
  const swapIndexes = (array: any[], a: number, b: number) => {
    const bItem = array[b];
    array[b] = array[a];
    array[a] = bItem;
    return [...array];
  };

  const handleDelete = (sectionId: string) => {
    if (setSections) {
      const nextSections: ISectionProps[] = [];
      sections.forEach(s => {
        if (s.id !== sectionId) {
          nextSections.push(s);
        }
      });
      const update: IPageProps = {id, sections: nextSections };
      setSections(update);
    }
  };

  /*
   * When a new section is dragged somewhere else:
   */
  const onDragEnd = (e: DropResult) => {
    if (e.destination && e.destination.index !== e.source.index) {
      const nextSections = swapIndexes(sections, e.source.index, e.destination.index);
      if (setSections) {
        setSections({id, sections: nextSections});
      }
    }
  };

  return (
    <DragDropContext onDragEnd={onDragEnd}>
    <Droppable droppableId="droppable">
      {(droppableProvided, snapshot) => (
        <div ref={droppableProvided.innerRef}
          className="edit-page-container"
          {...droppableProvided.droppableProps}>
          {
            sections.map( (sProps, index) => (
              <Draggable
                key={sProps.id}
                draggableId={sProps.id}
                index={index}>
              {
                (draggableProvided) => (
                  <div
                    {...draggableProvided.draggableProps}
                    ref={draggableProvided.innerRef}>
                      <AuthoringSection {...sProps}
                        {...draggableProvided}
                        key={sProps.id}
                        updateFunction={changeSection}
                        deleteFunction={handleDelete}
                        allSectionItems={allSectionItems}
                        addPageItem={addPageItem}
                         />
                    </div>
                  )
              }
              </Draggable>
            ))
          }
          { droppableProvided.placeholder }
          <button className="big-button" onClick={addSection}>
            + Add Section
          </button>
        </div>
      )}
    </Droppable>
    </DragDropContext>
  );
};
