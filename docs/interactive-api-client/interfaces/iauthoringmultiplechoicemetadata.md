[@concord-consortium/lara-interactive-api](../README.md) › [Globals](../globals.md) › [IAuthoringMultipleChoiceMetadata](iauthoringmultiplechoicemetadata.md)

# Interface: IAuthoringMultipleChoiceMetadata

## Hierarchy

* [IAuthoringMetadataBase](iauthoringmetadatabase.md)

  ↳ **IAuthoringMultipleChoiceMetadata**

## Index

### Properties

* [choices](iauthoringmultiplechoicemetadata.md#choices)
* [multipleAnswers](iauthoringmultiplechoicemetadata.md#optional-multipleanswers)
* [prompt](iauthoringmultiplechoicemetadata.md#optional-prompt)
* [questionSubType](iauthoringmultiplechoicemetadata.md#optional-questionsubtype)
* [questionType](iauthoringmultiplechoicemetadata.md#questiontype)
* [required](iauthoringmultiplechoicemetadata.md#optional-required)

## Properties

###  choices

• **choices**: *[IAuthoringMultipleChoiceChoiceMetadata](iauthoringmultiplechoicechoicemetadata.md)[]*

___

### `Optional` multipleAnswers

• **multipleAnswers**? : *undefined | false | true*

Whether the question accepts multiple simultaneous answers. When omitted, consumers should
treat it as undefined (not false) — single-answer behavior is the legacy default but is not
implied by absence. LARA surfaces this verbatim as `multiple_answers` on the report-service
structure document.

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
