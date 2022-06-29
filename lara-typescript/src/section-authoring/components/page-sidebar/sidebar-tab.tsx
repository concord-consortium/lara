import React from "react";
import { IconArrow } from "./icon-arrow-circle-left";

import "./sidebar-tab.scss";

interface IProps {
  handleShowSidebarContent: (index: number, show: boolean) => void;
  index: number;
  title: string | null;
  sidebarOpen: boolean;
}

export class SidebarTab extends React.PureComponent<IProps>{
  constructor(props: IProps) {
    super(props);
  }

  public render() {
    return (
      <div className="sidebar-tab" onClick={this.handleSidebarShow} onKeyDown={this.handleSidebarShow} 
           data-cy="sidebar-tab" tabIndex={0}>
        <div className={`icon ${this.props.sidebarOpen ? "open" : ""}`}>
          <IconArrow />
        </div>
        <div className="tab-name" data-cy="sidebar-tab-title">{this.props.title}</div>
      </div>
    );
  }

  private handleSidebarShow = () => {
    this.props.handleShowSidebarContent(this.props.index, !this.props.sidebarOpen);
  }
}
