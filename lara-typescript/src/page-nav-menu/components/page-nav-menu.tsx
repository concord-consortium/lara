import * as React from "react";
import { useState, useEffect } from "react";
import classNames from "classnames";
import { ISectionProps } from "../../section-authoring/components/authoring-section";
import { PageCopyDialog } from "./page-copy-dialog";
import { Previous } from "../../shared/components/icons/previous-icon";
import { Home } from "../../shared/components/icons/home-icon";
import { Next } from "../../shared/components/icons/next-icon";
import { Completion } from "../../shared/components/icons/completion-icon";
import { Add } from "../../shared/components/icons/add-icon";
import { Copy } from "../../shared/components/icons/copy-icon";
import { IPage } from "../../section-authoring/api/api-types";

import "./page-nav-menu.scss";

export interface IPageNavMenuProps {
  pages: IPage[];
  currentPageIndex: number | null;
  copyingPage: boolean;
}

export const PageNavMenu: React.FC<IPageNavMenuProps> = ({
  pages: initPages = [],
  currentPageIndex: initCurrentPage = 0,
  copyingPage: initCopyingPage = false
  }: IPageNavMenuProps) => {

  const [currentPageIndex, setCurrentPageIndex] = useState(initCurrentPage);
  const [pages, setPages] = useState([...initPages]);
  const [copyingPage, setCopyingPage] = useState(initCopyingPage);

  useEffect(() => {
    setPages(initPages);
  }, [initPages]);

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
    const allowNavigation = pageNum !== pages.length;
    if (allowNavigation) {
      setCurrentPageIndex(pageNum);
    }
  };

  const handleAddPageButtonClick = () => {
    const newPageNum = (pages.length + 1).toString();
    const id = newPageNum;
    const title = `Page ${newPageNum}`;
    const sections: ISectionProps[] = [];
    const pageIndex = pages.length;
    addPage(id, title, sections, pageIndex);
  };

  const handleCopyPageButtonClick = () => {
    toggleCopyPageDialog();
  };

  const addPage = (id: string, title: string, sections: ISectionProps[], pageIndex: number) => {
    const newPage = {
      id,
      title,
      sections,
      is_completion: false
    };
    pages.splice(pageIndex, 0, newPage);
    setPages([...pages]);
    setCurrentPageIndex(pageIndex);
  };

  const toggleCopyPageDialog = () => {
    setCopyingPage(!copyingPage);
  };

  const copyPage = (pageId: string, position: string, otherPageId: string) => {
    const copiedPage = pages.find(i => i.id === pageId);
    const otherPageIndex = pages.findIndex(i => i.id === otherPageId);
    const newPageIndex = position === "before" ? otherPageIndex : otherPageIndex + 1;
    const newPageNum = (pages.length + 1).toString();
    const id = newPageNum;
    const title = copiedPage?.title ? copiedPage.title : `Page ${newPageNum}`;
    const sections: ISectionProps[] = [];
    addPage(id, title, sections, newPageIndex);
    toggleCopyPageDialog();
  };

  const prevPage = currentPageIndex && currentPageIndex > 0 ? currentPageIndex - 1 : null;
  const nextPage = currentPageIndex === null
                     ? 0
                     : currentPageIndex < pages.length - 1
                       ? currentPageIndex + 1 : pages.length - 1;
  const currentPageIsCopyable = currentPageIndex !== null && !pages[currentPageIndex].isCompletion;
  const prevPageClassName = `page-button ${currentPageIndex === null ? "disabled " : ""}`;
  const prevClickHandler = () => handleNavButtonClick(prevPage);
  const nextPageClassName = `page-button ${currentPageIndex === pages.length - 1 ? "disabled" : ""}`;
  const nextClickHandler = () => handleNavButtonClick(nextPage);
  const homeButtonClassName = `page-button ${currentPageIndex === null ? "current" : ""}`;
  const homeClickHandler = () => handleNavButtonClick(null);
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
            onClick={homeClickHandler}>
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
          closeDialogFunction={toggleCopyPageDialog} />}
    </>
  );
};
