import { current } from "immer";
import * as React from "react";
import { PageId } from "../api/api-types";

import { usePageAPI } from "../hooks/use-api-provider";
import { RelativeLocation } from "../util/move-utils";

export const useDestinationChooser = () => {
  const { getPages, currentPage } = usePageAPI();
  const [selectedPageId, setSelectedPageId] = React.useState("0");
  const [selectedSectionId, setSelectedSectionId] = React.useState("");
  const [sections, setSections] = React.useState(currentPage?.sections || []);
  const [selectedPosition, setSelectedPosition] = React.useState(RelativeLocation.After);

  const pagesForPicking = getPages.data ? getPages.data.map(p => p.id) : [];

  React.useEffect( () => {
    if (getPages.data) {
      const foundPage = getPages.data.find(p => p.id.toString() === selectedPageId);
      setSections(foundPage?.sections || []);
    }
  }, [selectedPageId]);

  React.useEffect( () => {
    if (currentPage) {
      setSections(currentPage?.sections || []);
    }
  }, [currentPage]);

  const handlePageChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    const pageId = change.target.value;
    setSelectedPageId(pageId);
  };

  const handleSectionChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedSectionId(change.target.value);
  };

  const handlePositionChange = (change: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedPosition(change.target.value as RelativeLocation);
  };

  return {
    sections, selectedSectionId, selectedPageId,
    handlePageChange, handleSectionChange,
    handlePositionChange, selectedPosition,
    pagesForPicking
  };
};
