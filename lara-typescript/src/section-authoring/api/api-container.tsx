import * as React from "react";
import { QueryClient, QueryClientProvider } from "react-query";
import { APIContext } from "./use-api-provider";
import { IAuthoringAPIProvider } from "./api-types";
import { API as mockProvider } from "./mock-api-provider";
import { getLaraAuthoringAPI } from "./lara-api-provider";
import { UserInterfaceContext, UserInterfaceProvider } from "./user-interface-provider";
import { ReactQueryDevtools } from "react-query/devtools";

export interface IAPIContainerProps {
  activityId?: string;
  host?: string;
}

export const APIContainer: React.FC<IAPIContainerProps> = (props) => {
  const {activityId, host} = props;
  const queryClient = new QueryClient();
  const ui = React.useContext(UserInterfaceContext);

  let APIProvider: IAuthoringAPIProvider = mockProvider;
  if (activityId && host) {
    APIProvider = getLaraAuthoringAPI(activityId, host);
  }

  return (
    <UserInterfaceProvider>
      <APIContext.Provider value={APIProvider}>
        <QueryClientProvider client={queryClient}>
          <ReactQueryDevtools />
          {props.children}
        </QueryClientProvider>
      </APIContext.Provider>
    </UserInterfaceProvider>
  );
};
