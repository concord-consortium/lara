import React from "react";
import { Sidebar } from "./sidebar";

const kSidebarOffset = 100;

export interface SidebarConfiguration {
  content: string | null;
  title: string | null;
}

interface IProps {
  sidebars: SidebarConfiguration[];
  verticalOffset: number;
}

interface IState {
  showSidebarContent: boolean[];
}

export class SidebarWrapper extends React.PureComponent<IProps, IState> {
  constructor(props: IProps) {
    super(props);
    this.state = { showSidebarContent: new Array(props.sidebars.length).fill(false) };
  }
  public render() {
    const { sidebars, verticalOffset } = this.props;
    return (
      <React.Fragment>
        {sidebars.map((sidebar: SidebarConfiguration, index: number) => (
          <Sidebar
            key={`sidebar-${index}`}
            content={sidebar.content || ""}
            handleShowSidebar={this.setShowSidebarContent}
            index={index}
            show={this.state.showSidebarContent[index]}
            style={{ top: verticalOffset + kSidebarOffset * index}}
            title={sidebar.title || ""}
          />
        ))}
      </React.Fragment>
    );
  }

  private setShowSidebarContent = (index: number, show: boolean) => {
    this.setState(state => {
      const updatedShowSidebarContent = new Array(state.showSidebarContent.length).fill(false);
      updatedShowSidebarContent[index] = show;
      return { showSidebarContent: updatedShowSidebarContent };
    });
  }
}
