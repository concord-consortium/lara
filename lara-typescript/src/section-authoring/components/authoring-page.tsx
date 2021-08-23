import * as React from "react";
import { AuthoringSection, ISectionProps } from "./authoring-section";

import "./authoring-page.css";

export interface IPageProps {

  /**
   * Record ID
   */
  id: number;

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
   * how to change a section
   */
  changeSection?: (changes: Partial<ISectionProps>, id: number) => void;
}

/**
 * Primary UI component for user interaction
 */
export const AuthoringPage: React.FC<IPageProps> = ({
  id,
  title,
  sections = [],
  addSection,
  changeSection
  }: IPageProps) => {

  return (
    <div className="edit-page-container">
      {sections.map(sProps => <AuthoringSection {...sProps} key={sProps.id} updateFunction={changeSection} />)}
      <button className="big-button" onClick={addSection}>
        + Add Section
      </button>
    </div>
  );
};
