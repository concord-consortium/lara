[@concord-consortium/lara-interactive-api - v0.7.0-pre.1](../README.md) › [Globals](../globals.md) › [IAuthoringMultipleChoiceMetadata](iauthoringmultiplechoicemetadata.md)

# Interface: IAuthoringMultipleChoiceMetadata

## Hierarchy

* [IAuthoringMetadataBase](iauthoringmetadatabase.md)

  ↳ **IAuthoringMultipleChoiceMetadata**

## Index

### Properties

* [choices](iauthoringmultiplechoicemetadata.md#choices)
* [prompt](iauthoringmultiplechoicemetadata.md#optional-prompt)
* [questionSubType](iauthoringmultiplechoicemetadata.md#optional-questionsubtype)
* [questionType](iauthoringmultiplechoicemetadata.md#questiontype)
* [required](iauthoringmultiplechoicemetadata.md#optional-required)

## Properties

###  choices

• **choices**: *[IAuthoringMultipleChoiceChoiceMetadata](iauthoringmultiplechoicechoicemetadata.md)[]*

___

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

• **questionType**: *"multiple_choice"*

*Overrides [IAuthoringMetadataBase](iauthoringmetadatabase.md).[questionType](iauthoringmetadatabase.md#questiontype)*

___

### `Optional` required

• **required**? : *undefined | false | true*

*Inherited from [IAuthoringMetadataBase](iauthoringmetadatabase.md).[required](iauthoringmetadatabase.md#optional-required)*
