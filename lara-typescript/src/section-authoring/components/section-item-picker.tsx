import React, { useState } from 'react';

import "./section-item-picker.css"

export interface ItemType {
  name: string,
  use_count: number,
  date_added: number
}

export interface IProps {
  availableItemTypes: ItemType[],
  quickAddItems: ItemType[],
  allItems: ItemType[],
  matchingItems: ItemType[]
}

export const SectionItemPicker: React.FC<IProps> = (props) => {
  const { allItems, quickAddItems } = props;
  let { matchingItems } = props;
  const [itemSelected, setItemSelected] = useState(false);
  const [currentSelectedItem, setCurrentSelectedItem] = useState("");
  const [allItemsList, setAllItemsList] = useState(allItems);
  const [isSearching, setIsSearching] = useState(false);

  const setItemClasses = (isSelectedItem: boolean) => {
    const classes = isSelectedItem ? "assessmentItemOption selected" 
                                   : currentSelectedItem !== "" 
                                     ? "assessmentItemOption disabled"
                                     : "assessmentItemOption";
    return classes;
  }

  const handleListSort = (event: any) => {
    const allItemsSorted = [...allItems];
    const sortType = event.target.value;
    if (sortType === "popularity") {
      allItemsSorted.sort((a, b) => {
        return b.use_count - a.use_count;
      })
    }
    if (sortType === "date") {
      allItemsSorted.sort((a, b) => {
        return b.date_added - a.date_added;
      })
    }
    if (sortType === "alpha-asc") {
      allItemsSorted.sort((a, b) => {
        return (a.name).localeCompare(b.name);
      })
    }
    if (sortType === "alpha-desc") {
      allItemsSorted.sort((a, b) => {
        return (a.name).localeCompare(b.name);
      })
      allItemsSorted.reverse();
    }
    setAllItemsList(allItemsSorted);
  }

  const handleItemClick = (event: any, itemName: string) => {
    const selectedItem = currentSelectedItem !== itemName ? itemName : "";
    setItemSelected(!itemSelected);
    setCurrentSelectedItem(selectedItem);
  }

  const handleSearch = (event: any) => {
    setIsSearching(true);
    const searchString = event.target.value;
    matchingItems = [];
    if (searchString !== "") {
      allItems.forEach((item) => {
        const regex = new RegExp(searchString, "i");
        if (item.name.match(regex)) {
          matchingItems.push(item);
        }
      });
      setAllItemsList(matchingItems);
    } else {
      setAllItemsList(allItems);
    }
 
    setTimeout(() => { setIsSearching(false) }, 1000);
  }

  const handleAddButtonClick = (event: any) => {
    console.log(`Add button clicked. ${currentSelectedItem} selected.`);
  }

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
        {allItemsList.map((t, index) => {
          const isSelectedItem = currentSelectedItem === t.name
          const itemClass = setItemClasses(isSelectedItem);
          const itemDisabled = itemSelected && !isSelectedItem ? true : false;
          return <li key={`ai-${index}`}><button disabled={itemDisabled} className={itemClass} onClick={(e) => handleItemClick(e, t.name)}>{t.name}</button></li>
        })}
      </ul>
    );
  }

  return (
    <div id="itemPicker" className="modal">
      <header>
        <h1>Choose Assessment Item</h1>
        <button className="modalClose">close</button>
      </header>
      <section>
        <div id="quickAddMenu">
          <h2>Quick-Add Items</h2>
          <ul>
            {quickAddItems.map((t, index) => {
              const isSelectedItem = currentSelectedItem === t.name
              const itemClass = setItemClasses(isSelectedItem);
              const itemDisabled = itemSelected && !isSelectedItem ? true : false;
              return <li key={`qai-${index}`}><button disabled={itemDisabled} className={itemClass} onClick={(e) => handleItemClick(e, t.name)}>{t.name}</button></li>
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
        <div className="actionButton">
          <button disabled={!itemSelected} className={itemSelected ? "enabled add" : "disabled add"} onClick={handleAddButtonClick}>Add Item</button>
        </div>
      </section>
    </div>
  )
};