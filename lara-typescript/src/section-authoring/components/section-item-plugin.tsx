import * as React from "react";
import { UserInterfaceContext } from "../containers/user-interface-provider";
import { IPluginEmbeddable } from "../api/api-types";
import { usePageAPI } from "../hooks/use-api-provider";

import "./section-item-plugin-list.scss";

interface ISectionItemPluginProps {
  key: string;
  plugin: IPluginEmbeddable;
  wrappedSectionItemId: string;
}

export const SectionItemPlugin: React.FC<ISectionItemPluginProps> = ({
  key,
  plugin,
  wrappedSectionItemId
  }: ISectionItemPluginProps) => {
  const { name, sectionItemId } = plugin;
  const api = usePageAPI();
  const { userInterface: {editingItemId}, actions: {setEditingItemId}} = React.useContext(UserInterfaceContext);
  const { userInterface: {wrappedItemId}, actions: {setWrappedItemId}} = React.useContext(UserInterfaceContext);

  const handleEdit = () => {
    setEditingItemId(sectionItemId.toString());
    setWrappedItemId(wrappedSectionItemId.toString());
  };

  const handleDelete = () => {
    confirm("Are you sure you want to delete this plugin?") && api.deletePageItem(sectionItemId);
  };

  return (
    <li key={key}>
      <span className="pluginName">
        {name}
      </span>
      <button onClick={handleEdit}>
        Edit
      </button>
      <button onClick={handleDelete}>
        Delete
      </button>
    </li>
  );

};
