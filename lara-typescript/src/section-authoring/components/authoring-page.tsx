import * as React from "react";
import { AuthoringSection, ISectionProps } from "./authoring-section";
import { DragDropContext, Droppable, Draggable, DropResult } from "react-beautiful-dnd";

import "./authoring-page.css";
import { isCompositeComponentWithType } from "react-dom/test-utils";

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
   * how to add a new section
   */
   addSection?: () => void;

  /**
   *
   */
  changeSection?: (changes: Partial<ISectionProps>, id: string) => void;

  /*
   * Call back to invoke when sections have been rearranged or deleted
   */
  setSections?: (pageData: IPageProps) => void;

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
        if (s.id != sectionId) {
          nextSections.push(s);
          console.log(`keeping ID : ${s.id}`);
        }
        else {
          console.log(`removing ID : ${s.id}`);
        }
      });
      const update: IPageProps = {id, sections: nextSections };
      console.warn(update);
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
                    {...draggableProvided.dragHandleProps}
                    ref={draggableProvided.innerRef}>
                      <AuthoringSection {...sProps}
                        key={sProps.id}
                        updateFunction={changeSection}
                        deleteFunction={handleDelete} />
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
