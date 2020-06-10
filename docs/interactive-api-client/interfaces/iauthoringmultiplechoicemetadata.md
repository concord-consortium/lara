[@concord-consortium/lara-interactive-api - v0.4.0-pre.9](../README.md) › [Globals](../globals.md) › [IAuthoringMultipleChoiceMetadata](iauthoringmultiplechoicemetadata.md)

# Interface: IAuthoringMultipleChoiceMetadata

## Hierarchy

* [IAuthoringMetadataBase](iauthoringmetadatabase.md)

  ↳ **IAuthoringMultipleChoiceMetadata**

## Index

### Properties

* [choices](iauthoringmultiplechoicemetadata.md#choices)
* [prompt](iauthoringmultiplechoicemetadata.md#optional-prompt)
* [questionType](iauthoringmultiplechoicemetadata.md#questiontype)
* [required](iauthoringmultiplechoicemetadata.md#optional-required)
* [subtype](iauthoringmultiplechoicemetadata.md#optional-subtype)

## Properties

###  choices

• **choices**: *[IAuthoringMultipleChoiceChoiceMetadata](iauthoringmultiplechoicechoicemetadata.md)[]*

___

### `Optional` prompt

• **prompt**? : *undefined | string*

*Inherited from [IAuthoringMetadataBase](iauthoringmetadatabase.md).[prompt](iauthoringmetadatabase.md#optional-prompt)*

___

###  questionType

• **questionType**: *"multiple_choice"*

*Overrides [IAuthoringMetadataBase](iauthoringmetadatabase.md).[questionType](iauthoringmetadatabase.md#questiontype)*

___

### `Optional` required

• **required**? : *undefined | false | true*

*Inherited from [IAuthoringMetadataBase](iauthoringmetadatabase.md).[required](iauthoringmetadatabase.md#optional-required)*

___

### `Optional` subtype

• **subtype**? : *undefined | string*

*Inherited from [IAuthoringMetadataBase](iauthoringmetadatabase.md).[subtype](iauthoringmetadatabase.md#optional-subtype)*

Interactive can optionally set subtype, so Teacher Report can display different icons
or categorize interactives into subcategories.
