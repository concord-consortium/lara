[@concord-consortium/lara-interactive-api - v0.6.0](../README.md) › [Globals](../globals.md) › [IAuthoringInteractiveMetadata](iauthoringinteractivemetadata.md)

# Interface: IAuthoringInteractiveMetadata

Generic interactive type.

## Hierarchy

* [IAuthoringMetadataBase](iauthoringmetadatabase.md)

  ↳ **IAuthoringInteractiveMetadata**

## Index

### Properties

* [prompt](iauthoringinteractivemetadata.md#optional-prompt)
* [questionSubType](iauthoringinteractivemetadata.md#optional-questionsubtype)
* [questionType](iauthoringinteractivemetadata.md#questiontype)
* [required](iauthoringinteractivemetadata.md#optional-required)

## Properties

### `Optional` prompt

• **prompt**? : *undefined | string*

*Inherited from [IAuthoringMetadataBase](iauthoringmetadatabase.md).[prompt](iauthoringmetadatabase.md#optional-prompt)*

___

### `Optional` questionSubType

• **questionSubType**? : *undefined | string*

*Inherited from [IAuthoringMetadataBase](iauthoringmetadatabase.md).[questionSubType](iauthoringmetadatabase.md#optional-questionsubtype)*

Interactive can optionally set questionSubType, so Teacher Report can display different icons
or categorize interactives into subcategories.

___

###  questionType

• **questionType**: *"iframe_interactive"*

*Overrides [IAuthoringMetadataBase](iauthoringmetadatabase.md).[questionType](iauthoringmetadatabase.md#questiontype)*

___

### `Optional` required

• **required**? : *undefined | false | true*

*Inherited from [IAuthoringMetadataBase](iauthoringmetadatabase.md).[required](iauthoringmetadatabase.md#optional-required)*
