import React from "react";
import { withReactContext } from "storybook-react-context";
import { QueryClient, QueryClientProvider} from "react-query";

import {Layouts, ISectionProps } from "../section-authoring/components/authoring-section";
import {IPageProps, AuthoringPage} from "../section-authoring/components/authoring-page";
import { QueryBoundPage } from "../section-authoring/components/query-bound-page";

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

  const changeSection = (changes: {section: Partial<ISectionProps>}) => {
    const { section } = changes;
    debugger;
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

AuthoringPageStory.decorators = [withReactContext({initialState})];
AuthoringPageStory.title = "Authoring Page (with sections)";

export default AuthoringPageStory;

export const LaraConnectedPageStory = () => {
  const queryClient = new QueryClient();
  return(
    <QueryClientProvider client={queryClient}>
      <QueryBoundPage host="https://app.lara.docker" id="698" sections={[]}/>
    </QueryClientProvider>
  );
};
LaraConnectedPageStory.title = "Connected to LARA ... ";

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
