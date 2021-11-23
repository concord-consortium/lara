import * as React from "react";
import classNames from "classnames";
import { PageCopyDialog } from "./page-copy-dialog";
import { Previous } from "../../../shared/components/icons/previous-icon";
import { Home } from "../../../shared/components/icons/home-icon";
import { Next } from "../../../shared/components/icons/next-icon";
import { Completion } from "../../../shared/components/icons/completion-icon";
import { Add } from "../../../shared/components/icons/add-icon";
import { Copy } from "../../../shared/components/icons/copy-icon";
import { IPage, PageId } from "../../api/api-types";

import "./page-nav-menu.scss";

export interface IPageNavMenuProps {
  pages: IPage[];
  currentPageId: PageId | null;
  copyingPage: boolean;
  setCurrentPageId: (id: PageId) => void;
  addPage: () => void;
  copyPage: (destIndex: number) => void;
  deletePage: () => void;
  showCopyDialog: () => void;
  hideCopyDialog: () => void;
}

export const PageNavMenu: React.FC<IPageNavMenuProps> = ({
  pages,
  currentPageId,
  copyingPage,
  addPage,
  copyPage,
  setCurrentPageId,
  deletePage,
  showCopyDialog,
  hideCopyDialog
  }: IPageNavMenuProps) => {

  const currentPageIndex = pages.findIndex(p => p.id === currentPageId);
  const currentPage = pages[currentPageIndex];
  const pageButtons = () => {
    const buttons = pages.map((p, index) => {
      const pageNumber = index + 1;
      const buttonContent = p.isCompletion ? <Completion height="24" width="24" /> : pageNumber;
      const buttonClasses = classNames("page-button", {
        current: index === currentPageIndex,
        completionPage: p.isCompletion
      });
      const clickHandler = () => handleNavButtonClick(index);
      return <button
        key={`page-${index}-button`}
        className={buttonClasses}
        data-cy="nav-pages-button"
        aria-label={`Page ${index}`}
        onClick={clickHandler}>
          {buttonContent}
        </button>;
    });
    return buttons;
  };

  const handleNavButtonClick = (pageNum: number | null) => {
    if (pageNum == null) { return; }
    const outsideIndex = pageNum < 0 || pageNum + 1 > pages.length;
    if (!outsideIndex) {
      setCurrentPageId(pages[pageNum].id);
    }
  };

  const handleAddPageButtonClick = () => {
    addPage();
  };

  const handleCopyPageButtonClick = () => {
    showCopyDialog();
  };

  const handleHomeButtonClick = () => {
    const activityPath = window.location.pathname.split("/pages")[0];
    window.location.href = activityPath + "/edit";
  };

  const prevPage = currentPageIndex && currentPageIndex > 0 ? currentPageIndex - 1 : null;
  const nextPage = currentPageIndex === null
                     ? 0
                     : currentPageIndex < pages.length - 1
                       ? currentPageIndex + 1 : pages.length - 1;
  const currentPageIsCopyable = currentPageIndex !== null && !currentPage?.isCompletion;
  const prevPageClassName = `page-button ${currentPageIndex === null ? "disabled " : ""}`;
  const prevClickHandler = () => handleNavButtonClick(prevPage);
  const nextPageClassName = `page-button ${currentPageIndex === pages.length - 1 ? "disabled" : ""}`;
  const nextClickHandler = () => handleNavButtonClick(nextPage);
  const homeButtonClassName = `page-button ${currentPageIndex === null ? "current" : ""}`;
  const homeClickHandler = () =>  handleHomeButtonClick();
  const copyPageClassName = `page-button ${!currentPageIsCopyable ? "disabled" : ""}`;
  const copyClickHandler = currentPageIsCopyable ? handleCopyPageButtonClick : undefined;

  return (
    <>
      <nav className="activity-nav" data-cy="activity-nav">
        <div className="nav-pages" data-cy="nav-pages">
          <button
            className={prevPageClassName}
            aria-label="Previous Page"
            onClick={prevClickHandler}>
            <Previous height="24" width="24" />
          </button>
          <button
            className={homeButtonClassName}
            aria-label="Home"
            onClick={handleHomeButtonClick}>
            <Home height="24" width="24" />
          </button>
          {pageButtons()}
          <button
            className={nextPageClassName}
            aria-label="Next Page"
            onClick={nextClickHandler}>
            <Next height="24" width="24" />
          </button>
          <button
            className="page-button"
            aria-label="Add Page"
            onClick={handleAddPageButtonClick}>
            <Add height="24" width="24" />
          </button>
          <button
            className={copyPageClassName}
            aria-label="Copy Page"
            onClick={copyClickHandler}>
            <Copy height="24" width="24" />
          </button>
        </div>
      </nav>
      { copyingPage &&
        <PageCopyDialog
          pageId={"1"}
          pages={pages}
          currentPageIndex={currentPageIndex}
          copyPageFunction={copyPage}
          closeDialogFunction={hideCopyDialog} />}
    </>
  );
};
