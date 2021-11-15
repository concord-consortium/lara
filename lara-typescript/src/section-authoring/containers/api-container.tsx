import * as React from "react";
import { QueryClient, QueryClientProvider } from "react-query";
import { APIContext } from "../hooks/use-api-provider";
import { IAuthoringAPIProvider } from "../api/api-types";
import { API as mockProvider } from "../api/mock-api-provider";
import { getLaraAuthoringAPI } from "../api/lara-api-provider";
import { UserInterfaceContext, UserInterfaceProvider } from "./user-interface-provider";
import { ReactQueryDevtools } from "react-query/devtools";

export interface IAPIContainerProps {
  activityId?: string;
  host?: string;
  pageId?: string;
}

export const APIContainer: React.FC<IAPIContainerProps> = (props) => {
  const {activityId, host, pageId} = props;
  const queryClient = new QueryClient();
  const ui = React.useContext(UserInterfaceContext);
  const {actions} = ui;
  if (pageId) {
    actions.setCurrentPageId(pageId);
  }
  let APIProvider: IAuthoringAPIProvider = mockProvider;
  if (activityId && host) {
    APIProvider = getLaraAuthoringAPI(activityId, host);
  }

  return (
    <UserInterfaceProvider>
      <APIContext.Provider value={APIProvider}>
        <QueryClientProvider client={queryClient}>
          {/* Handy for debugging ReactQuery: */}
          {/* <ReactQueryDevtools /> */}
          {props.children}
        </QueryClientProvider>
      </APIContext.Provider>
    </UserInterfaceProvider>
  );
};
