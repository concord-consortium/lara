import React, { useState, useEffect } from "react";
import { IPageProps } from "../../section-authoring/components/authoring-page";
import { ISectionProps } from "../../section-authoring/components/authoring-section";
import { PageCopyDialog } from "./page-copy-dialog";
import { Add } from "./icons/add-icon";
import { Copy } from "./icons/copy-icon";

import "./page-nav-menu.css";

export interface IPageNavMenuProps {
  pages: IPageProps[];
  currentPageIndex: number;
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

  const handleNavButtonClick = (pageNum: number) => {
    setCurrentPageIndex(pageNum);
  }

  const handleAddPageButtonClick = () => {
    const newPageNum = (pages.length + 1).toString();
    const id = newPageNum;
    const title = `Page ${newPageNum}`;
    const sections: ISectionProps[] = [];
    const pageIndex = pages.length;
    addPage(id, title, sections, pageIndex);
  }

  const handleCopyPageButtonClick = () => {
    toggleCopyPageDialog();
  }

  const addPage = (id: string, title: string, sections: ISectionProps[], pageIndex: number) => {
    const newPage = {
      id,
      title,
      sections
    }
    pages.splice(pageIndex, 0, newPage);
    setPages([...pages]);
    setCurrentPageIndex(pageIndex);
  }

  const toggleCopyPageDialog = () => {
    setCopyingPage(!copyingPage);
  }

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
  }

  const prevPage = currentPageIndex > 0 ? currentPageIndex - 1 : currentPageIndex;
  const nextPage = currentPageIndex < pages.length - 1 ? currentPageIndex + 1 : currentPageIndex;

  return (
    <>
      <nav className="activity-nav" data-cy="activity-nav">
        <div className="nav-pages" data-cy="nav-pages">
          <button className={`page-button ${currentPageIndex === 0 ? "disabled ": ""}`} aria-label="Previous Page" onClick={() => handleNavButtonClick(prevPage)}>
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="#0592AF" className="icon">
              <path d="M15.67 3.87L13.9 2.1 4 12l9.9 9.9 1.77-1.77L7.54 12z"></path>
            </svg>
          </button>
          {/* It may be useful to include a home button in the page nav but I'm not sure yet. 
          <button className={`page-button ${currentPageIndex === null ? "current" : ""}`} aria-label="Home" onClick={() => handleNavButtonClick(null)}>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="25 0 1613 2048" className={`icon ${currentPageIndex === null ? "current" : ""}`} width="28" height="28">
              <path d="M1408 1120v480c0 17.333-6.333 32.333-19 45s-27.667 19-45 19H960v-384H704v384H320c-17.333 0-32.333-6.333-45-19s-19-27.667-19-45v-480c0-.667.167-1.667.5-3s.5-2.333.5-3l575-474 575 474c.667 1.333 1 3.333 1 6zm223-69l-62 74c-5.333 6-12.333 9.667-21 11h-3c-8.667 0-15.667-2.333-21-7L832 552l-692 577c-8 5.333-16 7.667-24 7-8.667-1.333-15.667-5-21-11l-62-74c-5.333-6.667-7.667-14.5-7-23.5s4.333-16.167 11-21.5l719-599c21.333-17.333 46.667-26 76-26s54.667 8.667 76 26l244 204V416c0-9.333 3-17 9-23s13.667-9 23-9h192c9.333 0 17 3 23 9s9 13.667 9 23v408l219 182c6.667 5.333 10.333 12.5 11 21.5s-1.667 16.833-7 23.5z"></path>
            </svg>
          </button> */}
          {pages.map((p, index) => {
            return <button key={`page-${index}-button`} className={`page-button ${index === currentPageIndex ? "current" : ""}`} data-cy="nav-pages-button" aria-label={`Page ${index}`} onClick={() => handleNavButtonClick(index)}>{index + 1}</button>
          })}
          <button className={`page-button ${currentPageIndex === pages.length - 1 ? "disabled" : ""}`} aria-label="Next Page" onClick={() => handleNavButtonClick(nextPage)}>
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="#0592AF" className="icon">
              <path d="M8.33 20.13l1.77 1.77L20 12l-9.9-9.9-1.77 1.77L16.46 12z"></path>
            </svg>
          </button>
          <button className="page-button" aria-label="Add Page" onClick={handleAddPageButtonClick}>
            <Add height="24" width="24"/>
          </button>
          <button className="page-button" aria-label="Copy Page" onClick={handleCopyPageButtonClick}>
            <Copy height="24" width="24"/>
          </button>
        </div>
      </nav>
      {copyingPage && <PageCopyDialog pageId={"1"} pages={pages} currentPageIndex={currentPageIndex} copyPageFunction={copyPage} closeDialogFunction={toggleCopyPageDialog} />}
    </>
  );
};
