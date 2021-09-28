import * as React from "react";
import { withReactContext } from "storybook-react-context";
import { QueryClient, QueryClientProvider} from "react-query";
import { ISectionProps } from "../section-authoring/components/authoring-section";
import { IPageProps, AuthoringPage} from "../section-authoring/components/authoring-page";
import { SectionLayouts  } from "../section-authoring/api/api-types";
import { QueryBoundPage } from "../section-authoring/components/query-bound-page";

const pageId = "1";
const initialState = {
  sections: [
    { id: "1", layout: SectionLayouts.LAYOUT_30_70, position: 1 },
    { id: "2", layout: SectionLayouts.LAYOUT_30_70, position: 2 },
  ]
};

interface IContext {
  context: [state: IPageProps, dispatch: (args: Partial<IPageProps>) => void];
}

let sectionIdCounter = 3;
let sectionPositionCounter = 3;

export const AuthoringPageStory = (_: any, { context: [state, dispatch] }: IContext) => {
  const addSection = () => {
    const nextState: Partial<IPageProps> = {
      sections: [...state.sections,
        {
          id: `${++sectionIdCounter}`,
          layout: SectionLayouts.LAYOUT_30_70,
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
      <QueryBoundPage host="https://app.lara.docker" id="3522" sections={[]}/>
    </QueryClientProvider>
  );
};
LaraConnectedPageStory.title = "Connected to LARA ... ";
