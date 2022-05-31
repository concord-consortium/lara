export type EmbeddableContext = string;
export type PluginScope = "activity" | "embeddable" | "embeddable-decoration";

export interface IPluginAuthoringMetaDataComponent {
  label: string;
  name: string;
  scope: PluginScope;
  decorates?: EmbeddableContext[];
  guiAuthoring?: boolean;
  guiPreview?: boolean;
}

export interface IPluginType {
  id: number;    // database ID (number on server, string here?)
  name: string;  // The display name for the plugin, shown in the GUI.
  url: string;
  description: string;
  label: string; // The lookup label for the plugin. No spaces or special characters.
  authoring_metadata: {
    components: IPluginAuthoringMetaDataComponent[];
  };
  version: 3;
  // Other fields omitted for now.
}
