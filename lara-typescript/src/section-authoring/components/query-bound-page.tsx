import * as React from "react";
import { APIContainer } from "../containers/api-container";
import { AuthoringPageUsingAPI, IPageProps } from "./authoring-page";

export interface IQueryBoundPage extends IPageProps {
  host?: string;
  activityId?: string;
  isAdmin?: boolean;
}

export const QueryBoundPage = (props: IQueryBoundPage) => {
  const host = props.host || "https://app.lara.docker";
  const activityId = props.activityId || "55";
  return (
    <APIContainer activityId={activityId} host={host} isAdmin={props.isAdmin}>
      <AuthoringPageUsingAPI />
    </APIContainer>
  );
};
