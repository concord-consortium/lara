import * as React from "react";

export interface ItemType {
  name: string
}

export interface IProps {
  availableItemTypes: ItemType[],
  quickAddItems: ItemType[]
}

export const SectionItemPicker: React.FC<IProps> = (props) => {
  const { quickAddItems } = props;
  return (
    <div>
      <header>
        <h1>Item Picker</h1>
      </header>
      <div id="quick-add-menu">
        <h2>Quick Add Items</h2>
        <ul>
          {quickAddItems.map((t) => {
            return <li>{t.name}</li>
          })}
        </ul>
        <div id="item-picker-options">
          <input id="item-picker-search" /> 
        </div>
        <div id="item-picker-list">
          <ul>
            <li>Carousel</li>
            <li>CODAP</li>
            <li>Drag &amp; Drop</li>
            <li>Fill in the Blank</li>
            <li>iFrame Interactive</li> 
            <li>Multiple Choice</li>
            <li>Open Response</li>
            <li>SageModeler</li>
            <li>Text Block</li>
          </ul>
        </div>
      </div>
    </div>
  )
};