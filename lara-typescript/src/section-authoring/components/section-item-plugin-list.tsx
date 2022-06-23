import * as React from "react";
import { ICreatePageItem, IPluginEmbeddable, SectionColumns } from "../api/api-types";
import { UserInterfaceContext } from "../containers/user-interface-provider";
import { useGetAvailablePlugins, useGetPageItemEmbeddableMetaData,
         useGetPageItemPlugins, usePageAPI } from "../hooks/use-api-provider";
import { SectionItemPlugin } from "./section-item-plugin";

import "./section-item-plugin-list.scss";

interface ISectionItemPluginListProps {
  sectionColumn: SectionColumns;
  sectionId: string;
  sectionItemId: string;
}

export const SectionItemPluginList: React.FC<ISectionItemPluginListProps> = ({
  sectionColumn,
  sectionId,
  sectionItemId
  }: ISectionItemPluginListProps) => {
  const availablePlugins = useGetAvailablePlugins();
  const pageItemPlugins = useGetPageItemPlugins(sectionItemId);
  const pageItemEmbeddableMetaData = useGetPageItemEmbeddableMetaData(sectionItemId);
  const {
    userInterface: {editingItemId, wrappedItemId},
    actions: {setEditingItemId, setWrappedItemId}
  } = React.useContext(UserInterfaceContext);
  const api = usePageAPI();
  const [selectedPluginType, setSelectedPluginType] = React.useState<string>("");

  const handlePluginSelect = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedPluginType(e.target.value);
  };

  const handleAdd = () => {
    if (selectedPluginType === "") {
      alert("Please select a plugin type.");
      return;
    }
    const itemPosition = 0;
    setWrappedItemId(sectionItemId);
    const newItem: ICreatePageItem = {
      column: sectionColumn,
      embeddable: selectedPluginType,
      position: itemPosition,
      section_id: sectionId,
      wrapped_embeddable_id: pageItemEmbeddableMetaData.data?.embeddableId,
      wrapped_embeddable_type: pageItemEmbeddableMetaData.data?.embeddableType
    };
    api.addPageItem(newItem);
  };

  const renderPluginsMenu = () => {
    if (!availablePlugins.isSuccess) {
      return null;
    }
    const unusedPlugins = availablePlugins.data.plugins.filter((ap: Record<string, any>) => {
      return !pageItemPlugins?.some((pip: IPluginEmbeddable) => {
        return pip.name === ap.name;
      });
    });

    const pluginOptions = unusedPlugins.map((up: Record<string, any>, i: number) => {
      const pluginValue = `Plugin_${up.id}::${up.component_label}`;
      return (
        <option
          key={`available-plugin-${sectionItemId}-${i}`}
          value={pluginValue}
          data-approved-script-id={up.id}
          data-component-label={up.label}
        >
          {up.name}
        </option>
      );
    });

    return (
      <div className="availablePlugins">
        <select
          id={`embeddable_type_embeddable-managed_interactive_${sectionItemId}`}
          name="embeddable_type"
          onChange={handlePluginSelect}
          disabled={pluginOptions.length === 0}
        >
          <option value="">Select a plugin:</option>
          {pluginOptions}
        </select>
        <button onClick={handleAdd} disabled={pluginOptions.length === 0}>
          Add
        </button>
      </div>
    );
  };

  const renderPluginsList = () => {
    const existingPlugins = pageItemPlugins?.map((p: any, i: number) => {
      return (
        <SectionItemPlugin
          wrappedSectionItemId={sectionItemId}
          plugin={p}
          key={`existing-plugin-${sectionItemId}-${i}`}
        />
      );
    });

    if (existingPlugins?.length === 0) {
      return null;
    }

    return (
      <div className="pluginsList">
        <h5>Existing Wrapping Plugins</h5>
        <ul>
          {existingPlugins}
        </ul>
      </div>
    );
  };

  return <>
    {availablePlugins && renderPluginsMenu()}
    {pageItemPlugins && pageItemPlugins?.length > 0 && renderPluginsList()}
  </>;

};
