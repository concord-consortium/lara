[@concord-consortium/lara-interactive-api](../README.md) › [Globals](../globals.md) › [IDataset](idataset.md)

# Interface: IDataset

Interface that can be used by interactives to export and consume datasets. For example:
- Vortex interactive is exporting its dataset in the interactive state
- Graph interactive (part of the question-interactives) can observe Vortex interactive state
  (via linked interactive state observing API) and render dataset columns as bar graphs.

## Hierarchy

* **IDataset**

## Index

### Properties

* [properties](idataset.md#properties)
* [rows](idataset.md#rows)
* [type](idataset.md#type)
* [version](idataset.md#version)
* [xAxisProp](idataset.md#xaxisprop)

## Properties

###  properties

• **properties**: *string[]*

___

###  rows

• **rows**: *Array‹Array‹undefined | null | string | number››*

___

###  type

• **type**: *"dataset"*

___

###  version

• **version**: *1*

___

###  xAxisProp

• **xAxisProp**: *string*
