import * as React from "react";
import { QueryClient, QueryClientProvider } from "react-query";
import { APIContext } from "./use-api-provider";
import { IAuthoringAPIProvider } from "./api-types";
import { API as mockProvider } from "./mock-api-provider";
import { getLaraAuthoringAPI } from "./lara-api-provider";
import { UserInterfaceContext, useUserInterface } from "./use-user-interface-context";
export interface IAPIContainerProps {
  activityId?: string;
  host?: string;
}

export const APIContainer: React.FC<IAPIContainerProps> = (props) => {
  const {activityId, host} = props;
  const queryClient = new QueryClient();
  const ui = useUserInterface();

  let APIProvider: IAuthoringAPIProvider = mockProvider;
  if (activityId && host) {
    APIProvider = getLaraAuthoringAPI(activityId, host);
  }

  return (
    <UserInterfaceContext.Provider value={ui}>
      <APIContext.Provider value={APIProvider}>
        <QueryClientProvider client={queryClient}>
          {props.children}
        </QueryClientProvider>
      </APIContext.Provider>
    </UserInterfaceContext.Provider>
  );
};
