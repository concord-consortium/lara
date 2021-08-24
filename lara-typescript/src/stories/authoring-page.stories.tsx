import React from "react";
import { withReactContext } from "storybook-react-context";

import {Layouts, ISectionProps } from "../section-authoring/components/authoring-section";
import {IPageProps, AuthoringPage} from "../section-authoring/components/authoring-page";

const pageId = "1";
const initialState = {
  sections: [ { id: "1", layout: Layouts.LAYOUT_30_70 } ]
};

interface IContext {
  context: [state: IPageProps, dispatch: (args: Partial<IPageProps>) => void];
}

let sectionIdCounter = 3;

export const AuthoringPageStory = (_: any, { context: [state, dispatch] }: IContext) => {
  const addSection = () => {
    const nextState: Partial<IPageProps> = {
      sections: [...state.sections,
        {
          id: `${++sectionIdCounter}`,
          layout: Layouts.LAYOUT_30_70,
          interactive_page_id: pageId
        }
      ]
    };
    dispatch(nextState);
  };

  const changeSection = (changes: Partial<ISectionProps>, id: string) => {
    const newSections = state.sections.map (section => {
      if (section.id === id) {
        return {...section, ...changes};
      }
      return section;
    });
    dispatch({sections: newSections});
  };

  const setSections = (newSections: ISectionProps[]) => {
    dispatch({sections: newSections});
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

AuthoringPageStory.decorators = [withReactContext({initialState})];
AuthoringPageStory.title = "Authoring Page (with sections)";

export default AuthoringPageStory;

// const Template: ComponentStory<typeof AuthoringPage> = (args: IPageProps) => <AuthoringPage {...args} />;

// export const withTwoSections = Template.bind({});
// const sections = [
//   {
//     id: 1,
//     layout: Layouts.LAYOUT_30_70
//   },
//   {
//     id: 2,
//     layout: Layouts.LAYOUT_70_30
//   }
// ];

// const addSection = () => {
//   console.log("Nee!");
//   sections.push({id: 3, layout: Layouts.LAYOUT_FULL_WIDTH});
// };

// withTwoSections.args  = {
//   id: 1,
//   sections,
//   addSection
// } as IPageProps;
