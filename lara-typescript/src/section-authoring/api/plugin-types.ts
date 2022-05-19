
/*
 Sample Plugin Authoring Meta Data, see: src/plugin-api/README.md#Plugin manifests

 Glossary looks like this:
 {
  "components": [
    {
      "label":"glossary",
      "name":"Activity",
      "scope":"activity",
      "guiAuthoring":true
    }]
  }
}

TeacherEdition looks like this:

{
  "components":[
    {
      "label":"windowShade",
      "name":"Window Shades",
      "scope":"embeddable",
      "guiAuthoring":true
    },{
      "label":"sideTip",
      "name":"Side Tips",
      "scope":"embeddable",
      "guiAuthoring":true
    },{
      "label":"questionWrapper",
      "name":"Question Wrapper",
      "scope":"embeddable-decoration",
      "decorates": [
        "Embeddable::MultipleChoice",
        "Embeddable::OpenResponse",
        "Embeddable::ImageQuestion",
        "ManagedInteractive",
        "MwInteractive",
        "ImageInteractive",
        "VideoInteractive"
      ],
      "guiAuthoring":true,
      "guiPreview": true
    }
  ]
}

*/

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
