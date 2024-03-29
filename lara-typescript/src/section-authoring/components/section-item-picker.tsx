import * as React from "react";
import { useState, useEffect, useMemo } from "react";
import classNames from "classnames";
import { Modal, ModalButtons } from "../../shared/components/modal/modal";
import { Add } from "../../shared/components/icons/add-icon";
import { absorbClickThen } from "../../shared/absorb-click";
import { ILibraryInteractive, ISectionItemType } from "../api/api-types";
import { usePageAPI } from "../hooks/use-api-provider";

import "./section-item-picker.scss";

export interface IProps {
  onClose: () => void;
  onAdd: (id: string) => void;
}

const SectionItemButton = ({item, disabled, className, onClick}: {
  item: ISectionItemType;
  disabled: boolean;
  className: string;
  onClick: (item: ISectionItemType) => void;
}) => {
  const handleItemClick = absorbClickThen(() => onClick(item));
  return <button disabled={disabled} className={className} onClick={handleItemClick}>{item.name}</button>;
};

export const SectionItemPicker: React.FC<IProps> = (props) => {
  const api = usePageAPI();
  const allItems = useMemo(() => {
    if (!api.getAllEmbeddables.data) {
      return undefined;
    }
    // filter out non-official embeddables if the user is not an admin
    const allEmbeddables = api.getAllEmbeddables.data.allEmbeddables.filter(em => {
      const official = (em as unknown as ILibraryInteractive).official ?? false;
      return api.isAdmin || official;
    });
    return {allEmbeddables};
  }, [api.getAllEmbeddables.data, api.isAdmin]);
  const quickAddItems = allItems?.allEmbeddables.filter(e => e.isQuickAddItem);
  const { onClose, onAdd } = props;
  const modalIsVisible = true;
  const [currentSelectedItem, setCurrentSelectedItem]
    = useState<ISectionItemType|null>(null);
  const [allItemsList, setAllItemsList] = useState(allItems?.allEmbeddables || []);
  const [isSearching, setIsSearching] = useState(false);
  const [modalVisibility, setModalVisibility] = useState(modalIsVisible);
  const itemSelected = currentSelectedItem !== null;

  // Escape key deselects the current item:
  const deselect = (event: KeyboardEvent) => {
    if (event.key === "Escape") {
      setCurrentSelectedItem(null);
    }
  };

  useEffect(() => {
    document.addEventListener("keydown", deselect, false);
    return () => {
      document.removeEventListener("keydown", deselect, false);
    };
  }, []);

  useEffect(() => {
    sortItems("alpha-asc");
  }, [allItems]);

  const sortItems = (sortType: string) => {
    if (!allItems?.allEmbeddables) { return []; }

    const allItemsSorted = [...allItems?.allEmbeddables];
    if (sortType === "popularity") {
      allItemsSorted.sort((a, b) => {
        return b.useCount - a.useCount;
      });
    }
    if (sortType === "date") {
      allItemsSorted.sort((a, b) => {
        return b.dateAdded - a.dateAdded;
      });
    }
    if (sortType === "alpha-asc") {
      allItemsSorted.sort((a, b) => {
        return (a.name).localeCompare(b.name);
      });
    }
    if (sortType === "alpha-desc") {
      allItemsSorted.sort((a, b) => {
        return (a.name).localeCompare(b.name);
      });
      allItemsSorted.reverse();
    }
    setAllItemsList(allItemsSorted);
  };

  const setItemClasses = (isSelectedItem: boolean) => {
    const classes = classNames("assessmentItemOption", {
      selected: isSelectedItem,
      disabled: false
    });
    return classes;
  };

  const handleListSort = (event: React.ChangeEvent<HTMLSelectElement>) => sortItems(event.target.value);

  const handleItemClick = (item: ISectionItemType) => {
    if (currentSelectedItem !== item) {
      setCurrentSelectedItem(item);
    } else {
      setCurrentSelectedItem(null);
    }
  };

  const handleSearch = (event: React.ChangeEvent<HTMLInputElement>) => {
    setIsSearching(true);
    const searchString = event.target.value;
    const matchingItems: ISectionItemType[] = [];
    if (searchString !== "") {
      allItemsList.forEach((item) => {
        const regex = new RegExp(searchString, "i");
        if (item.name.match(regex)) {
          matchingItems.push(item);
        }
      });
      setAllItemsList(matchingItems);
    } else {
      setAllItemsList(allItems?.allEmbeddables || []);
    }

    setTimeout(() => { setIsSearching(false); }, 1000);
  };

  const handleAddButtonClick = absorbClickThen(() => {
    if (currentSelectedItem) {
      onAdd(currentSelectedItem.id);
    }
  });

  const handleCloseButtonClick = absorbClickThen(onClose);

  const renderAllItemsList = () => {
    if (isSearching) {
      return (
        <div id="searchPlaceholder" className="loading">
          <em>Searching...</em>
        </div>
      );
    }
    if (allItemsList.length === 0) {
      return (
        <div id="searchPlaceholder">
          <em>No assessment items found.</em>
        </div>
      );
    }
    return (
      <ul>
        {allItemsList.map((item, index) => {
          const isSelectedItem = currentSelectedItem === item;
          const itemClass = setItemClasses(isSelectedItem);
          return (
            <li key={`ai-${index}`}>
              <SectionItemButton
                item={item}
                disabled={false}
                className={itemClass}
                onClick={handleItemClick}
              />
            </li>
          );
        })}
      </ul>
    );
  };

  const buttonClasses = itemSelected ? "enabled add" : "disabled add";
  const modalButtons = [
    {
        classes: buttonClasses,
        clickHandler: handleAddButtonClick,
        disabled: false,
        svg: <Add height="16" width="16"/>,
        text: "Add Item"}
  ];

  return (
    <Modal
      closeFunction={handleCloseButtonClick}
      title="Choose Assessment Item"
      visibility={modalVisibility} width={600}
    >
      <div className="sectionItemPicker">
        <div id="quickAddMenu">
          <h2>Quick-Add Items</h2>
          <ul>
            {quickAddItems?.map((item, index) => {
              const isSelectedItem = currentSelectedItem === item;
              const itemClass = setItemClasses(isSelectedItem);
              const itemDisabled = false;
              return (
                <li key={`qai-${index}`}>
                  <SectionItemButton
                    item={item}
                    disabled={itemDisabled}
                    className={itemClass}
                    onClick={handleItemClick}
                  />
                </li>
              );
            })}
          </ul>
        </div>
        <div id="itemPickerOptions">
          <div id="itemPickerSearch">
            <input disabled={itemSelected} placeholder="Enter item name" onChange={handleSearch} />
          </div>
          <div id="itemPickerSort">
            <label className={itemSelected ? "disabled" : ""} htmlFor="itemPickerSort">Sort by:</label>
            <select disabled={itemSelected} onChange={handleListSort} defaultValue="alpha-asc">
              <option key="0-listSort" value="popularity">Most Popular</option>
              <option key="1-listSort" value="date">Most Recent</option>
              <option key="2-listSort" value="alpha-asc">Name (A-Z)</option>
              <option key="3-listSort" value="alpha-desc">Name (Z-A)</option>
            </select>
          </div>
        </div>
        <div id="itemPickerList">
          {renderAllItemsList()}
        </div>
        <ModalButtons buttons={modalButtons} />
      </div>
    </Modal>
  );
};
