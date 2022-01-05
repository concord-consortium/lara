import { current } from "immer";
import * as React from "react";
import { IPage, PageId } from "../api/api-types";

import { usePageAPI } from "../hooks/use-api-provider";
import { RelativeLocation } from "../util/move-utils";

export const useDestinationChooser = () => {
  const { getPages, currentPage } = usePageAPI();
  const [selectedPageId, setSelectedPageId] = React.useState("");
  const [selectedSectionId, setSelectedSectionId] = React.useState("");
  const [sections, setSections] = React.useState(currentPage?.sections || []);
  const [selectedPosition, setSelectedPosition] = React.useState(RelativeLocation.After);
  const [validPage, setValidPage] = React.useState(false);
  const [validSection, setValidSection] = React.useState(false);

  React.useEffect( () => {
    if (getPages.data) {
      const foundPage = getPages.data.find(p => p.id.toString() === selectedPageId);
      if (foundPage) {
        setValidPage(true);
      } else {
        setValidPage(false);
      }
      setSections(foundPage?.sections || []);
    }
  }, [selectedPageId, getPages]);

  React.useEffect( () => {
    if (currentPage && !validPage) {
      setSelectedPageId(currentPage.id);
    }
  }, [currentPage]);

  React.useEffect( () => {
    if (selectedSectionId.length > 0) {
      setValidSection(true);
    }
  }, [selectedSectionId]);

  const setPagesForPicking = (pageData: IPage[]) => {
    const pages = pageData.map((p: IPage) => {
      return {
        id: p.id,
        isCompletion: p.isCompletion,
        isHidden: p.isHidden
      };
    });
    return pages;
  };

  const pagesForPicking = getPages.data ? setPagesForPicking(getPages.data) : [];

  const handlePageChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    const pageId = change.target.value;
    setSelectedPageId(pageId);
    setSelectedSectionId("");
    setValidSection(false);
  };

  const handleSectionChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedSectionId(change.target.value);
  };

  const handlePositionChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedPosition(change.target.value as RelativeLocation);
  };

  return {
    sections, selectedSectionId, selectedPageId,
    handlePageChange, handleSectionChange, validPage,
    handlePositionChange, selectedPosition, validSection,
    pagesForPicking
  };
};
