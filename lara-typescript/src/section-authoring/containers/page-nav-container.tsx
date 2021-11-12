import * as React from "react";

import { PageNavMenu, IPageNavMenuProps } from "../components/page-nav-menu/page-nav-menu";
import { IPage, PageId } from "../api/api-types";
import { usePageAPI } from "../hooks/use-api-provider";
import { UserInterfaceContext} from "../containers/user-interface-provider";

export interface IPageNavContainerProps { }

export const PageNavContainer: React.FC<IPageNavContainerProps> = ({}) => {
  const { getPages, currentPage, addPage, copyPage } = usePageAPI();
  const ui = React.useContext(UserInterfaceContext);
  const [copyingPage, setCopyingPage] = React.useState(false);
  const pages = getPages.data;
  const canDisplay = pages && currentPage;
  const { setCurrentPageId } = ui.actions;
  if (!canDisplay) {
    return <div> please wait ... </div>;
  }

  const currentPageId = currentPage.id;

  const props: IPageNavMenuProps = {
    pages,
    currentPageId,
    copyingPage,
    setCurrentPageId,
    addPage,
    copyPage,
    deletePage: () => true,
    showCopyDialog: () => setCopyingPage(true),
    hideCopyDialog: () => setCopyingPage(false)
  };

  return (
    <PageNavMenu {...props} />
  );
};
