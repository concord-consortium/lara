import React from "react";
import { SidebarTab } from "./sidebar-tab";
import { SidebarPanel } from "./sidebar-panel";

import "./sidebar.scss";

interface IProps {
  content: string;
  handleShowSidebar: (index: number, show: boolean) => void;
  index: number;
  show: boolean;
  style?: any;
  title: string;
}

interface IState {
  showSidebarContent: boolean;
}

export class Sidebar extends React.PureComponent<IProps, IState> {
  constructor(props: IProps) {
    super(props);
    // eslint-disable-next-line react/no-unused-state
    this.state = { showSidebarContent: false };
  }
  public render() {
    const { content, handleShowSidebar, index, show, style, title } = this.props;
    return (
      <div className={`sidebar-container ${show ? "expanded" : ""}`} style={style} data-cy="sidebar">
        <SidebarTab
          handleShowSidebarContent={handleShowSidebar}
          index={index}
          sidebarOpen={show}
          title={title}
        />
        <SidebarPanel
          content={content}
          handleCloseSidebarContent={handleShowSidebar}
          index={index}
          title={title}
          show={show}
        />
      </div>
    );
  }
}
