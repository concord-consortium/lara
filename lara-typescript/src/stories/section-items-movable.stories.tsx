import * as React from "react";
import { withReactContext } from "storybook-react-context";

import {Layouts, ISectionProps } from "../section-authoring/components/authoring-section";
import {IPageProps, AuthoringPage} from "../section-authoring/components/authoring-page";

const pageId = "1";
const initialState = {
  sections: [ { id: "1", layout: Layouts.LAYOUT_40_60, interactive_page_id: "0", items: [] } ]
};

interface IContext {
  context: [state: IPageProps, dispatch: (args: Partial<IPageProps>) => void];
}

let sectionIdCounter = 1;

export const SectionItemsMovableStory = (_: any, { context: [state, dispatch] }: IContext) => {
  const addSection = () => {
    const nextState: Partial<IPageProps> = {
      sections: [...state.sections,
        {
          id: `${++sectionIdCounter}`,
          layout: Layouts.LAYOUT_40_60,
          interactive_page_id: pageId,
          items: []
        }
      ]
    };
    dispatch(nextState);
  };

  const changeSection = (changes: {section: Partial<ISectionProps>}) => {
    const { section } = changes;
    const newSections = state.sections.map (s => {
      if (s.id === section.id) {
        return {...s, ...changes.section};
      }
      return s;
    });
    dispatch({sections: newSections});
  };

  const setSections = (newPage: IPageProps) => {
    dispatch({sections: newPage.sections});
  };

  return (
    <AuthoringPage
      sections={state.sections}
      addSection={addSection}
      setSections={setSections}
      id={pageId}
      changeSection={changeSection}
      />
  );
};

SectionItemsMovableStory.decorators = [withReactContext({initialState})];
SectionItemsMovableStory.title = "Section Items Are Movable";

export default SectionItemsMovableStory;
