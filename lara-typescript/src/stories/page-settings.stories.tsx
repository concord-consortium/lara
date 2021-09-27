import * as React from "react";
import { withReactContext } from "storybook-react-context";
import {Layouts, ISectionProps } from "../section-authoring/components/authoring-section";
import {IPageProps, AuthoringPage} from "../section-authoring/components/authoring-page";

interface IContext {
  context: [state: IPageProps, dispatch: (args: Partial<IPageProps>) => void];
}

const pageId = "1";
const initialState = {};
let sectionIdCounter = 0;
let sectionPositionCounter = 0;

export const AuthoringPageSettingsStory = (_: any, { context: [state, dispatch] }: IContext) => {
  const addSection = () => {
    const nextState: Partial<IPageProps> = {
      sections: [...state.sections,
        {
          id: `${++sectionIdCounter}`,
          layout: Layouts.LAYOUT_30_70,
          position: ++sectionPositionCounter,
          interactive_page_id: pageId
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
      addSection={addSection}
      changeSection={changeSection}
      id={pageId}
      isNew={true}
      sections={state.sections}
      setSections={setSections}
    />
  );
};

AuthoringPageSettingsStory.decorators = [withReactContext({initialState})];
AuthoringPageSettingsStory.title = "Authoring Page Settings";

export default AuthoringPageSettingsStory;
