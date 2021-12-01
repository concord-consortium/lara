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

const kMaxPageNavigationButtons = 11;

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
  const [pageChangeInProgress, setPageChangeInProcess] = React.useState(false);

  const handleNavButtonClick = (pageNum: number | null) => {
    if (pageNum == null) {
      handleSelectHomeButton();
    } else {
      const outsideIndex = pageNum < 0 || pageNum + 1 > pages.length;
      if (!outsideIndex) {
        setCurrentPageId(pages[pageNum].id);
      }
    }
  };

  const handleAddPageButtonClick = () => {
    addPage();
  };

  const handleCopyPageButtonClick = () => {
    showCopyDialog();
  };

  const handleSelectHomeButton = () => {
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
  const copyPageClassName = `page-button ${!currentPageIsCopyable ? "disabled" : ""}`;
  const copyClickHandler = currentPageIsCopyable ? handleCopyPageButtonClick : undefined;

  const renderPreviousButton = () => {
    return (
      <button
        className={`page-button ${pageChangeInProgress || currentPageIndex === null ? "disabled" : ""}`}
        onClick={prevClickHandler}
        aria-label="Previous page"
      >
        <Previous height="24" width="24"/>
      </button>
    );
  };
  const renderNextButton = () => {
    const totalPages = pages.length;
    return (
      <button
        className={`page-button ${pageChangeInProgress || currentPageIndex + 1 === totalPages ? "disabled" : ""}`}
        onClick={nextClickHandler}
        aria-label="Next page"
      >
        <Next height="24" width="24"/>
      </button>
    );
  };

  const renderHomePageButton = () => {
    const currentClass = currentPageIndex === null ? "current" : "";
    return (
      <button
        className={`page-button ${currentClass} ${(pageChangeInProgress) ? "disabled" : ""}`}
        onClick={handleSelectHomeButton}
        aria-label="Home">
        <Home
          className={`icon ${currentClass}`}
          width="24"
          height="24"
        />
      </button>
    );
  };

  const renderPageButtons = () => {
    const totalPages = pages.length;
    const maxPagesLeftOfCurrent = currentPageIndex - 1;
    const maxPagesRightOfCurrent = totalPages - currentPageIndex;
    let minPage = 1;
    let maxPage = totalPages;
    const maxButtonsPerSide = Math.floor(kMaxPageNavigationButtons / 2);
    if (maxPagesLeftOfCurrent < maxButtonsPerSide) {
      maxPage =
        Math.min(totalPages, currentPageIndex + maxButtonsPerSide + (maxButtonsPerSide - maxPagesLeftOfCurrent));
    } else if (maxPagesRightOfCurrent < maxButtonsPerSide) {
      minPage = Math.max(1, currentPageIndex - maxButtonsPerSide - (maxButtonsPerSide - maxPagesRightOfCurrent));
    } else if (totalPages > kMaxPageNavigationButtons) {
      minPage = currentPageIndex - maxButtonsPerSide;
      maxPage = currentPageIndex + maxButtonsPerSide;
    }

    return (
      pages.map((page: any, pageIndex: number) => {
        const pageNum = pageIndex + 1;
        const currentClass = currentPageIndex === pageIndex ? "current" : "";
        const completionClass = page.isCompletion ? "completion-page-button" : "";
        const disabledClass = pageChangeInProgress ? "disabled" : "";
        const buttonContent = page.isCompletion
                              ? <Completion className={`icon ${currentClass}`} width="28" height="28" />
                              : pageNum;
        const clickHandler = () => handleNavButtonClick(pageIndex);

        return (
          pageNum >= minPage && pageNum <= maxPage
            ? <button
                className={`page-button ${currentClass} ${completionClass} ${disabledClass}`}
                onClick={clickHandler}
                key={`page ${pageNum}`}
                data-cy={`${page.is_completion ? "nav-pages-completion-page-button" : "nav-pages-button"}`}
                aria-label={`Page ${pageNum}`}
              >
                {buttonContent}
              </button>
            : ""
        );
      })
    );
  };

  const renderAddPageButton = () => {
    return (
      <button
        className="page-button"
        aria-label="Add Page"
        onClick={handleAddPageButtonClick}>
        <Add height="24" width="24" />
      </button>
    );
  };

  const renderCopyPageButton = () => {
    return (
      <button
        className={copyPageClassName}
        aria-label="Copy Page"
        onClick={copyClickHandler}>
        <Copy height="24" width="24" />
      </button>
    );
  };

  return (
    <>
      <nav className="activity-nav" data-cy="activity-nav">
        <div className="nav-pages" data-cy="nav-pages">
          {renderPreviousButton()}
          {renderHomePageButton()}
          {renderPageButtons()}
          {renderNextButton()}
          {renderAddPageButton()}
          {renderCopyPageButton()}
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
