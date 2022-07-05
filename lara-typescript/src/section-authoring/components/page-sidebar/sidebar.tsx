import * as React from "react";
import { SidebarTab } from "./sidebar-tab";
import { SidebarPanel } from "./sidebar-panel";

import "./sidebar.scss";
import { IPage } from "../../api/api-types";
import { ICustomReportFieldsAuthoredStateField } from "@concord-consortium/interactive-api-host";

interface IProps {
  content: string;
  updateSettingsFunction: (changes: Partial<IPage>) => void;
  index: number;
  style?: any;
  title: string;
}

interface IState {
  showSidebarContent: boolean;
}

export class Sidebar extends React.PureComponent<IProps, IState> {
  constructor(props: IProps) {
    super(props);
    this.state = { showSidebarContent: false };
  }

  public toggleShow = () => {
    this.setState(prevstate => {
      return { showSidebarContent: !prevstate.showSidebarContent };
    });
  }

  public render() {
    const { content, index, style, title, updateSettingsFunction } = this.props;
    const { showSidebarContent } = this.state;
    return (
      <div className={`sidebar-container ${showSidebarContent ? "expanded" : ""}`} style={style} data-cy="sidebar">
        <SidebarTab
          handleShowSidebarContent={this.toggleShow}
          index={index}
          sidebarOpen={showSidebarContent}
          title={title}
        />
        <SidebarPanel
          content={content}
          handleCloseSidebarContent={this.toggleShow}
          updateSettingsFunction={updateSettingsFunction}
          index={index}
          title={title}
          show={showSidebarContent}
        />
      </div>
    );
  }
}
